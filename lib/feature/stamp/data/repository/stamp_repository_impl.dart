import 'package:capstone_2026/feature/stamp/domain/model/stamp_reward_policy.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/repository/stamp_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StampRepositoryImpl implements StampRepository {
  StampRepositoryImpl({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  static const String _defaultEligibilityMessage =
      '예약 완료 후 리뷰 작성 시 스탬프가 적립됩니다.';
  static const String _reviewPromptMessage =
      '스탬프 적립을 위해 리뷰를 작성 해 주세요!';
  static const String _reviewCompletedMessage =
      '리뷰 작성이 완료된 매장입니다.';

  static const Map<String, StampRewardPolicy> _mockPolicies = {
    's1': StampRewardPolicy(
      storeId: 's1',
      storeName: '돈블랑 여의도점',
      goalCount: 10,
      rewardTitle: '와인 콜키지 1병 무료',
      rewardDescription: '스탬프 10개 적립 시 와인 콜키지 1병을 무료로 제공합니다.',
    ),
    's2': StampRewardPolicy(
      storeId: 's2',
      storeName: '블루보틀 여의도 카페',
      goalCount: 10,
      rewardTitle: '제조 음료 1잔 무료',
      rewardDescription: '스탬프 10개 적립 시 제조 음료 1잔을 무료로 제공합니다.',
    ),
    's3': StampRewardPolicy(
      storeId: 's3',
      storeName: '아이디헤어 브라이튼여의도점',
      goalCount: 10,
      rewardTitle: '두피 케어 서비스 제공',
      rewardDescription: '스탬프 10개 적립 시 두피 케어 서비스를 제공합니다.',
    ),
  };

  final SupabaseClient _supabase;

  final Map<String, Map<String, int>> _mockStampCountsByUserId = {};
  final Map<String, Set<String>> _mockVisitedStoreIdsByUserId = {};
  final Map<String, Set<String>> _mockReviewedStoreIdsByUserId = {};

  @override
  Future<StoreStampStatus> fetchStoreStampStatus({
    required String userId,
    required String storeId,
  }) async {
    try {
      final resolvedStore = await _resolveStore(storeId);
      if (resolvedStore == null || resolvedStore.dbStoreId == null) {
        return _buildMockStatus(userId: userId, storeId: storeId);
      }

      final status = await _buildDbStatusForStore(
        userId: userId,
        resolvedStore: resolvedStore,
      );
      return status ?? _buildMockStatus(userId: userId, storeId: storeId);
    } catch (e) {
      debugPrint('[StampRepository] fetchStoreStampStatus fallback: $e');
      return _buildMockStatus(userId: userId, storeId: storeId);
    }
  }

  @override
  Future<List<StoreStampStatus>> fetchUserStampStatuses({
    required String userId,
  }) async {
    try {
      final visitedStoreIds = await _fetchCompletedReservationStoreIds(userId);
      if (visitedStoreIds.isEmpty) {
        return const [];
      }

      final List<dynamic> storeRows = await _supabase
          .from('stores')
          .select('id, name')
          .inFilter('id', visitedStoreIds.toList());

      if (storeRows.isEmpty) {
        return _buildMockHistoryStatuses(userId: userId);
      }

      final storeMap = <String, _ResolvedStore>{};
      for (final row in storeRows.cast<Map<String, dynamic>>()) {
        final mapped = Map<String, dynamic>.from(row);
        final dbStoreId = mapped['id']?.toString();
        final storeName = mapped['name']?.toString() ?? '';
        if (dbStoreId == null || dbStoreId.isEmpty) {
          continue;
        }

        final appStoreId = _findAppStoreIdByName(storeName) ?? dbStoreId;
        storeMap[dbStoreId] = _ResolvedStore(
          appStoreId: appStoreId,
          dbStoreId: dbStoreId,
          storeName: storeName,
        );
      }

      if (storeMap.isEmpty) {
        return _buildMockHistoryStatuses(userId: userId);
      }

      final policyRows = await _supabase
          .from('stamp_policies')
          .select(
            'store_id, goal_count, reward_title, reward_description, is_active',
          )
          .inFilter('store_id', storeMap.keys.toList());

      final stampRows = await _supabase
          .from('user_store_stamps')
          .select('store_id, stamp_count, reward_unlocked_at')
          .eq('user_id', userId)
          .inFilter('store_id', storeMap.keys.toList());

      final policyMap = _mapPolicyRows(policyRows);
      final stampCountMap = _mapStampCountRows(stampRows);

      final statuses = storeMap.values.map((store) {
        final policy = _buildPolicyForStore(
          resolvedStore: store,
          policyRow: policyMap[store.dbStoreId],
        );
        final currentCount = stampCountMap[store.dbStoreId] ?? 0;
        final hasWrittenReview = currentCount > 0;
        return _buildStatus(
          appStoreId: store.appStoreId,
          policy: policy,
          currentCount: currentCount,
          hasVisited: true,
          hasWrittenReview: hasWrittenReview,
        );
      }).toList()
        ..sort((a, b) => b.currentCount.compareTo(a.currentCount));

      return statuses;
    } catch (e) {
      debugPrint('[StampRepository] fetchUserStampStatuses fallback: $e');
      return _buildMockHistoryStatuses(userId: userId);
    }
  }

  @override
  Future<StoreStampStatus> accrueStampForReview({
    required String userId,
    required String storeId,
  }) async {
    try {
      final resolvedStore = await _resolveStore(storeId);
      if (resolvedStore == null || resolvedStore.dbStoreId == null) {
        return _accrueMockStampForReview(userId: userId, storeId: storeId);
      }

      final currentStatus = await _buildDbStatusForStore(
        userId: userId,
        resolvedStore: resolvedStore,
      );
      if (currentStatus == null || !currentStatus.canWriteReview) {
        return currentStatus ?? _buildMockStatus(userId: userId, storeId: storeId);
      }

      final reservationId = await _fetchLatestCompletedReservationId(
        userId: userId,
        dbStoreId: resolvedStore.dbStoreId!,
      );

      await _accrueStampAtomically(
        userId: userId,
        dbStoreId: resolvedStore.dbStoreId!,
        reservationId: reservationId,
        currentStatus: currentStatus,
      );

      return await fetchStoreStampStatus(userId: userId, storeId: storeId);
    } catch (e) {
      debugPrint('[StampRepository] accrueStampForReview fallback: $e');
      return _accrueMockStampForReview(userId: userId, storeId: storeId);
    }
  }

  @override
  Future<StoreStampStatus> revokeStampForDeletedReview({
    required String userId,
    required String storeId,
  }) async {
    try {
      final resolvedStore = await _resolveStore(storeId);
      if (resolvedStore == null || resolvedStore.dbStoreId == null) {
        return _revokeMockStampForDeletedReview(userId: userId, storeId: storeId);
      }

      final currentStatus = await _buildDbStatusForStore(
        userId: userId,
        resolvedStore: resolvedStore,
      );
      if (currentStatus == null) {
        return _buildMockStatus(userId: userId, storeId: storeId);
      }

      final nextCount = currentStatus.currentCount > 0
          ? currentStatus.currentCount - 1
          : 0;

      await _supabase.from('user_store_stamps').upsert(
        {
          'store_id': resolvedStore.dbStoreId,
          'user_id': userId,
          'stamp_count': nextCount,
          'reward_unlocked_at': nextCount >= currentStatus.goalCount
              ? DateTime.now().toIso8601String()
              : null,
        },
        onConflict: 'store_id,user_id',
      );

      await _supabase.from('stamp_events').insert({
        'store_id': resolvedStore.dbStoreId,
        'user_id': userId,
        'delta': -1,
        'reason': 'review_deleted',
      });

      return await fetchStoreStampStatus(userId: userId, storeId: storeId);
    } catch (e) {
      debugPrint('[StampRepository] revokeStampForDeletedReview fallback: $e');
      return _revokeMockStampForDeletedReview(userId: userId, storeId: storeId);
    }
  }

  Future<_ResolvedStore?> _resolveStore(String storeId) async {
    final mockPolicy = _mockPolicies[storeId];
    if (mockPolicy != null) {
      final row = await _supabase
          .from('stores')
          .select('id, name')
          .eq('name', mockPolicy.storeName)
          .maybeSingle();

      if (row != null) {
        final mapped = Map<String, dynamic>.from(row);
        return _ResolvedStore(
          appStoreId: storeId,
          dbStoreId: mapped['id']?.toString(),
          storeName: mapped['name']?.toString() ?? mockPolicy.storeName,
        );
      }

      return _ResolvedStore(
        appStoreId: storeId,
        dbStoreId: null,
        storeName: mockPolicy.storeName,
      );
    }

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
          appStoreId: _findAppStoreIdByName(storeName) ?? storeId,
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
    await _supabase.from('user_store_stamps').upsert(
      {
        'store_id': dbStoreId,
        'user_id': userId,
        'stamp_count': nextCount,
        'last_reservation_id': reservationId,
        'reward_unlocked_at': nextCount >= currentStatus.goalCount
            ? DateTime.now().toIso8601String()
            : null,
      },
      onConflict: 'store_id,user_id',
    );

    await _supabase.from('stamp_events').insert({
      'store_id': dbStoreId,
      'user_id': userId,
      'reservation_id': reservationId,
      'delta': 1,
      'reason': 'review_created',
    });
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
        .select('stamp_count, reward_unlocked_at')
        .eq('user_id', userId)
        .eq('store_id', resolvedStore.dbStoreId!)
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
    final hasWrittenReview = currentCount > 0;

    return _buildStatus(
      appStoreId: resolvedStore.appStoreId,
      policy: policy,
      currentCount: currentCount,
      hasVisited: hasVisited,
      hasWrittenReview: hasWrittenReview,
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

  StampRewardPolicy _buildPolicyForStore({
    required _ResolvedStore resolvedStore,
    required Map<String, dynamic>? policyRow,
  }) {
    final fallbackPolicy = _mockPolicies[resolvedStore.appStoreId];
    return StampRewardPolicy(
      storeId: resolvedStore.appStoreId,
      storeName: resolvedStore.storeName,
      goalCount:
          ((policyRow?['goal_count'] as num?)?.toInt()) ??
          fallbackPolicy?.goalCount ??
          10,
      rewardTitle:
          policyRow?['reward_title']?.toString() ??
          fallbackPolicy?.rewardTitle ??
          '사장님 지정 보상',
      rewardDescription:
          policyRow?['reward_description']?.toString() ??
          fallbackPolicy?.rewardDescription ??
          '스탬프 목표 달성 시 매장별 보상을 받을 수 있습니다.',
    );
  }

  StoreStampStatus _buildStatus({
    required String appStoreId,
    required StampRewardPolicy policy,
    required int currentCount,
    required bool hasVisited,
    required bool hasWrittenReview,
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
      showInHistory: hasVisited,
      historyStatusMessage: hasWrittenReview ? '리뷰 작성 완료' : '리뷰 미작성',
      hasWrittenReview: hasWrittenReview,
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

  List<StoreStampStatus> _buildMockHistoryStatuses({
    required String userId,
  }) {
    _ensureMockUserState(userId);

    return _mockPolicies.keys
        .map((storeId) => _buildMockStatus(userId: userId, storeId: storeId))
        .where((status) => status.showInHistory)
        .toList()
      ..sort((a, b) => b.currentCount.compareTo(a.currentCount));
  }

  StoreStampStatus _buildMockStatus({
    required String userId,
    required String storeId,
  }) {
    _ensureMockUserState(userId);

    final policy =
        _mockPolicies[storeId] ??
        StampRewardPolicy(
          storeId: storeId,
          storeName: storeId,
          goalCount: 10,
          rewardTitle: '사장님 지정 보상',
          rewardDescription: '스탬프 목표 달성 시 매장별 보상을 받을 수 있습니다.',
        );

    final currentCount = _mockStampCountsByUserId[userId]![storeId] ?? 0;
    final hasVisited = _mockVisitedStoreIdsByUserId[userId]!.contains(storeId);
    final hasWrittenReview = _mockReviewedStoreIdsByUserId[userId]!.contains(
      storeId,
    );

    return _buildStatus(
      appStoreId: policy.storeId,
      policy: policy,
      currentCount: currentCount,
      hasVisited: hasVisited,
      hasWrittenReview: hasWrittenReview,
    );
  }

  StoreStampStatus _accrueMockStampForReview({
    required String userId,
    required String storeId,
  }) {
    _ensureMockUserState(userId);

    final current = _buildMockStatus(userId: userId, storeId: storeId);
    if (!current.canWriteReview) {
      return current;
    }

    final nextCount = (current.currentCount + 1).clamp(0, current.goalCount);
    _mockStampCountsByUserId[userId]![storeId] = nextCount;
    _mockReviewedStoreIdsByUserId[userId]!.add(storeId);

    return _buildMockStatus(userId: userId, storeId: storeId);
  }

  StoreStampStatus _revokeMockStampForDeletedReview({
    required String userId,
    required String storeId,
  }) {
    _ensureMockUserState(userId);

    final current = _buildMockStatus(userId: userId, storeId: storeId);
    final nextCount = (current.currentCount - 1).clamp(0, current.goalCount);
    _mockStampCountsByUserId[userId]![storeId] = nextCount;
    _mockReviewedStoreIdsByUserId[userId]!.remove(storeId);

    return _buildMockStatus(userId: userId, storeId: storeId);
  }

  void _ensureMockUserState(String userId) {
    _mockStampCountsByUserId.putIfAbsent(
      userId,
      () => {
        's1': 3,
        's2': 0,
        's3': 0,
      },
    );
    _mockVisitedStoreIdsByUserId.putIfAbsent(userId, () => {'s1', 's2'});
    _mockReviewedStoreIdsByUserId.putIfAbsent(userId, () => {'s1'});
  }

  String? _findAppStoreIdByName(String storeName) {
    for (final entry in _mockPolicies.entries) {
      if (entry.value.storeName == storeName) {
        return entry.key;
      }
    }
    return null;
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
