import 'package:capstone_2026/feature/stamp/domain/model/stamp_reward_policy.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/repository/stamp_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StampRepositoryImpl implements StampRepository {
  StampRepositoryImpl({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  static const bool _allowReviewStampTestingBypass = bool.fromEnvironment(
    'ALLOW_REVIEW_STAMP_TEST_BYPASS',
    defaultValue: !kReleaseMode,
  );

  static const String _defaultEligibilityMessage =
      '예약 완료 후 리뷰 작성 시 스탬프가 적립됩니다.';
  static const String _reviewPromptMessage = '스탬프 적립을 위해 리뷰를 작성해 주세요!';
  static const String _reviewCompletedMessage = '리뷰 작성이 완료된 매장입니다.';

  final SupabaseClient _supabase;

  @override
  Future<StoreStampStatus> fetchStoreStampStatus({
    required String userId,
    required String storeId,
  }) async {
    final resolvedStore = await _resolveStore(storeId);
    if (resolvedStore == null || resolvedStore.dbStoreId == null) {
      throw ArgumentError('해당 가게 정보를 찾을 수 없습니다.');
    }

    final status = await _buildDbStatusForStore(
      userId: userId,
      resolvedStore: resolvedStore,
    );

    if (status == null) {
      final policyRows = await _supabase
          .from('stamp_policies')
          .select('goal_count, reward_title, reward_description, is_active')
          .eq('store_id', resolvedStore.dbStoreId!)
          .limit(1);

      final policy = _buildPolicyForStore(
        resolvedStore: resolvedStore,
        policyRow: policyRows.isNotEmpty
            ? Map<String, dynamic>.from(policyRows.first as Map)
            : null,
      );
      return _buildStatus(
        appStoreId: storeId,
        policy: policy,
        currentCount: 0,
        hasVisited: false,
        hasWrittenReview: false,
      );
    }
    return status;
  }

  @override
  Future<List<StoreStampStatus>> fetchUserStampStatuses({
    required String userId,
  }) async {
    try {
      final visitedStoreIds = await _fetchCompletedReservationStoreIds(userId);
      final stampRows = await _supabase
          .from('user_store_stamps')
          .select(
            'store_id, stamp_count, reward_unlocked_at, reward_claimed_at',
          )
          .eq('user_id', userId);
      final reviewRows = await _supabase
          .from('reviews')
          .select('store_id')
          .eq('user_id', userId)
          .eq('is_visible', true);

      final stampedStoreIds = _extractStoreIds(stampRows);
      final reviewedStoreIds = _extractStoreIds(reviewRows);
      final historyStoreIds = {
        ...visitedStoreIds,
        ...stampedStoreIds,
        ...reviewedStoreIds,
      };

      if (historyStoreIds.isEmpty) {
        return const [];
      }

      final List<dynamic> storeRows = await _supabase
          .from('stores')
          .select('id, name')
          .inFilter('id', historyStoreIds.toList());

      if (storeRows.isEmpty) {
        return const [];
      }

      final storeMap = <String, _ResolvedStore>{};
      for (final row in storeRows.cast<Map<String, dynamic>>()) {
        final mapped = Map<String, dynamic>.from(row);
        final dbStoreId = mapped['id']?.toString();
        final storeName = mapped['name']?.toString() ?? '';
        if (dbStoreId == null || dbStoreId.isEmpty) {
          continue;
        }

        storeMap[dbStoreId] = _ResolvedStore(
          appStoreId: dbStoreId,
          dbStoreId: dbStoreId,
          storeName: storeName,
        );
      }

      if (storeMap.isEmpty) {
        return const [];
      }

      final policyRows = await _supabase
          .from('stamp_policies')
          .select(
            'store_id, goal_count, reward_title, reward_description, is_active',
          )
          .inFilter('store_id', storeMap.keys.toList());

      final policyMap = _mapPolicyRows(policyRows);
      final stampCountMap = _mapStampCountRows(stampRows);
      final claimedAtMap = _mapRewardClaimedAtRows(stampRows);

      final statuses = storeMap.values.map((store) {
        final policy = _buildPolicyForStore(
          resolvedStore: store,
          policyRow: policyMap[store.dbStoreId],
        );
        final currentCount = stampCountMap[store.dbStoreId] ?? 0;
        final hasWrittenReview = reviewedStoreIds.contains(store.dbStoreId);
        return _buildStatus(
          appStoreId: store.appStoreId,
          policy: policy,
          currentCount: currentCount,
          hasVisited: visitedStoreIds.contains(store.dbStoreId),
          hasWrittenReview: hasWrittenReview,
          forceShowInHistory: true,
          rewardClaimedAt: claimedAtMap[store.dbStoreId],
        );
      }).toList()..sort((a, b) => b.currentCount.compareTo(a.currentCount));

      return statuses;
    } catch (e) {
      debugPrint('[StampRepository] fetchUserStampStatuses failed: $e');
      return const [];
    }
  }

  @override
  Future<StoreStampStatus> accrueStampForReview({
    required String userId,
    required String storeId,
  }) async {
    final resolvedStore = await _resolveStore(storeId);
    if (resolvedStore == null || resolvedStore.dbStoreId == null) {
      throw ArgumentError('해당 가게 정보를 찾을 수 없습니다.');
    }

    final currentStatus = await _buildDbStatusForStore(
      userId: userId,
      resolvedStore: resolvedStore,
    );
    if (currentStatus == null) {
      throw StateError('스탬프 적립을 진행할 수 없습니다. 스탬프 정책이 존재하지 않습니다.');
    }

    if (!_allowReviewStampTestingBypass && !currentStatus.showInHistory) {
      return currentStatus;
    }

    final reservationId = await _fetchLatestCompletedReservationId(
      userId: userId,
      dbStoreId: resolvedStore.dbStoreId!,
    );

    await _accrueStampAtomically(
      userId: userId,
      dbStoreId: resolvedStore.dbStoreId!,
      reservationId: reservationId,
      currentStatus: currentStatus.copyWith(
        canWriteReview: true,
        hasWrittenReview: false,
      ),
    );

    return await fetchStoreStampStatus(userId: userId, storeId: storeId);
  }

  @override
  Future<StoreStampStatus> revokeStampForDeletedReview({
    required String userId,
    required String storeId,
  }) async {
    final resolvedStore = await _resolveStore(storeId);
    if (resolvedStore == null || resolvedStore.dbStoreId == null) {
      throw ArgumentError('해당 가게 정보를 찾을 수 없습니다.');
    }

    final currentStatus = await _buildDbStatusForStore(
      userId: userId,
      resolvedStore: resolvedStore,
    );
    if (currentStatus == null) {
      throw StateError('스탬프 정보가 존재하지 않습니다.');
    }

    final nextCount = currentStatus.currentCount > 0
        ? currentStatus.currentCount - 1
        : 0;

    await _saveStampCount(
      userId: userId,
      dbStoreId: resolvedStore.dbStoreId!,
      stampCount: nextCount,
      reservationId: null,
      rewardUnlockedAt: nextCount >= currentStatus.goalCount
          ? DateTime.now()
          : null,
    );
    if (nextCount < currentStatus.goalCount) {
      await _supabase
          .from('user_store_stamps')
          .update({
            'reward_claimed_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('store_id', resolvedStore.dbStoreId!);
    }

    await _supabase.from('stamp_events').insert({
      'store_id': resolvedStore.dbStoreId,
      'user_id': userId,
      'delta': -1,
      'reason': 'review_deleted',
    });

    return await fetchStoreStampStatus(userId: userId, storeId: storeId);
  }

  @override
  Future<StoreStampStatus> claimReward({
    required String userId,
    required String storeId,
  }) async {
    final resolvedStore = await _resolveStore(storeId);
    if (resolvedStore == null || resolvedStore.dbStoreId == null) {
      throw ArgumentError('해당 가게 정보를 찾을 수 없습니다.');
    }

    final currentStatus = await _buildDbStatusForStore(
      userId: userId,
      resolvedStore: resolvedStore,
    );
    if (currentStatus == null) {
      throw StateError('스탬프 정보가 존재하지 않습니다.');
    }
    if (!currentStatus.isRewardUnlocked) {
      return currentStatus;
    }
    final nextCount = currentStatus.currentCount - currentStatus.goalCount;
    final now = DateTime.now();

    await _supabase
        .from('user_store_stamps')
        .update({
          'stamp_count': nextCount,
          'reward_unlocked_at': nextCount >= currentStatus.goalCount
              ? now.toIso8601String()
              : null,
          'reward_claimed_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('store_id', resolvedStore.dbStoreId!);

    await _supabase.from('stamp_events').insert({
      'store_id': resolvedStore.dbStoreId,
      'user_id': userId,
      'delta': -currentStatus.goalCount,
      'reason': 'reward_claimed',
    });

    // 쿠폰 발급 연동
    await _supabase.from('coupons').insert({
      'user_id': userId,
      'store_id': resolvedStore.dbStoreId!,
      'reward_title': currentStatus.rewardTitle,
      'reward_description': currentStatus.rewardDescription,
      'expired_at': now.add(const Duration(days: 365)).toIso8601String(),
    });

    return await fetchStoreStampStatus(userId: userId, storeId: storeId);
  }

  Future<_ResolvedStore?> _resolveStore(String storeId) async {
    if (_isUuid(storeId)) {
      final row = await _supabase
          .from('stores')
          .select('id, name')
          .eq('id', storeId)
          .maybeSingle();

      if (row != null) {
        final mapped = Map<String, dynamic>.from(row);
        final storeName = mapped['name']?.toString() ?? storeId;
        return _ResolvedStore(
          appStoreId: storeId,
          dbStoreId: mapped['id']?.toString(),
          storeName: storeName,
        );
      }
    }
    return null;
  }

  Future<void> _accrueStampAtomically({
    required String userId,
    required String dbStoreId,
    required String? reservationId,
    required StoreStampStatus currentStatus,
  }) async {
    if (_allowReviewStampTestingBypass) {
      await _accrueStampWithClientFallback(
        userId: userId,
        dbStoreId: dbStoreId,
        reservationId: reservationId,
        currentStatus: currentStatus,
      );
      return;
    }

    try {
      await _supabase.rpc(
        'accrue_stamp_for_review',
        params: {
          'p_user_id': userId,
          'p_store_id': dbStoreId,
          'p_reservation_id': reservationId,
        },
      );
    } on PostgrestException catch (e) {
      debugPrint(
        '[StampRepository] accrue_stamp_for_review RPC fallback: ${e.message}',
      );
      await _accrueStampWithClientFallback(
        userId: userId,
        dbStoreId: dbStoreId,
        reservationId: reservationId,
        currentStatus: currentStatus,
      );
    }
  }

  Future<void> _accrueStampWithClientFallback({
    required String userId,
    required String dbStoreId,
    required String? reservationId,
    required StoreStampStatus currentStatus,
  }) async {
    final nextCount = currentStatus.currentCount + 1;
    await _saveStampCount(
      userId: userId,
      dbStoreId: dbStoreId,
      stampCount: nextCount,
      reservationId: reservationId,
      rewardUnlockedAt: nextCount >= currentStatus.goalCount
          ? DateTime.now()
          : null,
    );

    await _supabase.from('stamp_events').insert({
      'store_id': dbStoreId,
      'user_id': userId,
      'reservation_id': reservationId,
      'delta': 1,
      'reason': 'review_created',
    });
  }

  Future<void> _saveStampCount({
    required String userId,
    required String dbStoreId,
    required int stampCount,
    required String? reservationId,
    required DateTime? rewardUnlockedAt,
  }) async {
    final payload = <String, dynamic>{
      'store_id': dbStoreId,
      'user_id': userId,
      'stamp_count': stampCount,
      'last_reservation_id': reservationId,
      'reward_unlocked_at': rewardUnlockedAt?.toIso8601String(),
    };

    await _supabase
        .from('user_store_stamps')
        .upsert(
          payload,
          onConflict: 'user_id,store_id',
        );
  }

  Future<StoreStampStatus?> _buildDbStatusForStore({
    required String userId,
    required _ResolvedStore resolvedStore,
  }) async {
    if (resolvedStore.dbStoreId == null) {
      return null;
    }

    final List<dynamic> reservationRows = await _supabase
        .from('reservations')
        .select('id')
        .eq('user_id', userId)
        .eq('store_id', resolvedStore.dbStoreId!)
        .eq('status', 'completed')
        .limit(1);

    final hasVisited = reservationRows.isNotEmpty;

    final List<dynamic> policyRows = await _supabase
        .from('stamp_policies')
        .select(
          'store_id, goal_count, reward_title, reward_description, is_active',
        )
        .eq('store_id', resolvedStore.dbStoreId!)
        .limit(1);

    final List<dynamic> stampRows = await _supabase
        .from('user_store_stamps')
        .select('stamp_count, reward_unlocked_at, reward_claimed_at')
        .eq('user_id', userId)
        .eq('store_id', resolvedStore.dbStoreId!)
        .limit(1);

    final List<dynamic> reviewRows = await _supabase
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .eq('store_id', resolvedStore.dbStoreId!)
        .eq('is_visible', true)
        .limit(1);

    final policy = _buildPolicyForStore(
      resolvedStore: resolvedStore,
      policyRow: policyRows.isNotEmpty
          ? Map<String, dynamic>.from(policyRows.first as Map)
          : null,
    );
    final currentCount = stampRows.isNotEmpty
        ? ((Map<String, dynamic>.from(stampRows.first as Map)['stamp_count']
                      as num?) ??
                  0)
              .toInt()
        : 0;
    final rewardClaimedAt = stampRows.isNotEmpty
        ? _parseDateTime(
            Map<String, dynamic>.from(
              stampRows.first as Map,
            )['reward_claimed_at'],
          )
        : null;
    final hasWrittenReview = reviewRows.isNotEmpty;

    return _buildStatus(
      appStoreId: resolvedStore.appStoreId,
      policy: policy,
      currentCount: currentCount,
      hasVisited: hasVisited,
      hasWrittenReview: hasWrittenReview,
      rewardClaimedAt: rewardClaimedAt,
    );
  }

  Future<Set<String>> _fetchCompletedReservationStoreIds(String userId) async {
    final List<dynamic> rows = await _supabase
        .from('reservations')
        .select('store_id')
        .eq('user_id', userId)
        .eq('status', 'completed');

    return rows
        .cast<Map<String, dynamic>>()
        .map((row) => row['store_id']?.toString())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Future<String?> _fetchLatestCompletedReservationId({
    required String userId,
    required String dbStoreId,
  }) async {
    final row = await _supabase
        .from('reservations')
        .select('id')
        .eq('user_id', userId)
        .eq('store_id', dbStoreId)
        .eq('status', 'completed')
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row != null) {
      return row['id']?.toString();
    }
    return null;
  }

  Map<String, Map<String, dynamic>> _mapPolicyRows(dynamic rows) {
    if (rows is! List) {
      return const {};
    }

    final result = <String, Map<String, dynamic>>{};
    for (final row in rows.whereType<Map>()) {
      final mapped = Map<String, dynamic>.from(row);
      final storeId = mapped['store_id']?.toString();
      if (storeId == null || storeId.isEmpty) {
        continue;
      }
      result[storeId] = mapped;
    }
    return result;
  }

  Set<String> _extractStoreIds(dynamic rows) {
    if (rows is! List) {
      return const {};
    }

    return rows
        .whereType<Map>()
        .map((row) => row['store_id']?.toString())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  Map<String, int> _mapStampCountRows(dynamic rows) {
    if (rows is! List) {
      return const {};
    }

    final result = <String, int>{};
    for (final row in rows.whereType<Map>()) {
      final mapped = Map<String, dynamic>.from(row);
      final storeId = mapped['store_id']?.toString();
      if (storeId == null || storeId.isEmpty) {
        continue;
      }
      result[storeId] = ((mapped['stamp_count'] as num?) ?? 0).toInt();
    }
    return result;
  }

  Map<String, DateTime> _mapRewardClaimedAtRows(dynamic rows) {
    if (rows is! List) {
      return const {};
    }

    final result = <String, DateTime>{};
    for (final row in rows.whereType<Map>()) {
      final mapped = Map<String, dynamic>.from(row);
      final storeId = mapped['store_id']?.toString();
      final claimedAt = _parseDateTime(mapped['reward_claimed_at']);
      if (storeId == null || storeId.isEmpty || claimedAt == null) {
        continue;
      }
      result[storeId] = claimedAt;
    }
    return result;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  StampRewardPolicy _buildPolicyForStore({
    required _ResolvedStore resolvedStore,
    required Map<String, dynamic>? policyRow,
  }) {
    return StampRewardPolicy(
      storeId: resolvedStore.appStoreId,
      storeName: resolvedStore.storeName,
      goalCount: ((policyRow?['goal_count'] as num?)?.toInt()) ?? 10,
      rewardTitle: policyRow?['reward_title']?.toString() ?? '사장님 지정 보상',
      rewardDescription: policyRow?['reward_description']?.toString() ??
          '스탬프 목표 달성 시 매장별 보상을 받을 수 있습니다.',
      isActive: policyRow?['is_active'] == true,
    );
  }

  StoreStampStatus _buildStatus({
    required String appStoreId,
    required StampRewardPolicy policy,
    required int currentCount,
    required bool hasVisited,
    required bool hasWrittenReview,
    bool forceShowInHistory = false,
    DateTime? rewardClaimedAt,
  }) {
    return StoreStampStatus(
      storeId: appStoreId,
      storeName: policy.storeName,
      currentCount: currentCount,
      goalCount: policy.goalCount,
      rewardTitle: policy.rewardTitle,
      rewardDescription: policy.rewardDescription,
      canWriteReview: hasVisited && !hasWrittenReview,
      reviewEligibilityMessage: _buildEligibilityMessage(
        hasVisited: hasVisited,
        hasWrittenReview: hasWrittenReview,
      ),
      showInHistory: forceShowInHistory || hasVisited,
      historyStatusMessage: hasWrittenReview ? '리뷰 작성 완료' : '리뷰 미작성',
      hasWrittenReview: hasWrittenReview,
      rewardClaimedAt: rewardClaimedAt,
    );
  }

  String _buildEligibilityMessage({
    required bool hasVisited,
    required bool hasWrittenReview,
  }) {
    if (hasWrittenReview) {
      return _reviewCompletedMessage;
    }
    if (hasVisited) {
      return _reviewPromptMessage;
    }
    return _defaultEligibilityMessage;
  }

  @override
  Future<StampRewardPolicy?> fetchStampRewardPolicy({
    required String storeId,
  }) async {
    try {
      final resolvedStore = await _resolveStore(storeId);
      if (resolvedStore == null || resolvedStore.dbStoreId == null) {
        return null;
      }
      final row = await _supabase
          .from('stamp_policies')
          .select(
            'store_id, goal_count, reward_title, reward_description, is_active',
          )
          .eq('store_id', resolvedStore.dbStoreId!)
          .maybeSingle();

      if (row == null) return null;
      final mapped = Map<String, dynamic>.from(row);
      return StampRewardPolicy(
        storeId: storeId,
        storeName: resolvedStore.storeName,
        goalCount: ((mapped['goal_count'] as num?)?.toInt()) ?? 10,
        rewardTitle: mapped['reward_title']?.toString() ?? '',
        rewardDescription: mapped['reward_description']?.toString() ?? '',
        isActive: mapped['is_active'] == true,
      );
    } catch (e) {
      debugPrint('[StampRepository] fetchStampRewardPolicy failed: $e');
      return null;
    }
  }

  @override
  Future<void> saveStampRewardPolicy({
    required String storeId,
    required int goalCount,
    required String rewardTitle,
    required String rewardDescription,
    required bool isActive,
  }) async {
    final resolvedStore = await _resolveStore(storeId);
    final dbStoreId = resolvedStore?.dbStoreId ?? storeId;

    await _supabase.from('stamp_policies').upsert({
      'store_id': dbStoreId,
      'goal_count': goalCount,
      'reward_title': rewardTitle,
      'reward_description': rewardDescription,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }
}

class _ResolvedStore {
  const _ResolvedStore({
    required this.appStoreId,
    required this.dbStoreId,
    required this.storeName,
  });

  final String appStoreId;
  final String? dbStoreId;
  final String storeName;
}
