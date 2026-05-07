import 'package:capstone_2026/feature/stamp/domain/model/stamp_reward_policy.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/feature/stamp/domain/repository/stamp_repository.dart';

class StampRepositoryImpl implements StampRepository {
  static const String _defaultEligibilityMessage =
      '예약 완료 후 리뷰 작성 시 스탬프가 적립됩니다.';
  static const String _reviewPromptMessage =
      '스탬프 적립을 위해 리뷰를 작성 해 주세요!';
  static const String _reviewCompletedMessage =
      '이용 완료 후 리뷰 작성이 완료된 매장입니다.';

  final Map<String, StampRewardPolicy> _policies = const {
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

  final Map<String, Map<String, int>> _stampCountsByUserId = {};
  final Map<String, Set<String>> _visitedStoreIdsByUserId = {};
  final Map<String, Set<String>> _reviewedStoreIdsByUserId = {};

  @override
  Future<StoreStampStatus> fetchStoreStampStatus({
    required String userId,
    required String storeId,
  }) async {
    return _buildStatus(userId: userId, storeId: storeId);
  }

  @override
  Future<List<StoreStampStatus>> fetchUserStampStatuses({
    required String userId,
  }) async {
    _ensureUserState(userId);

    return _policies.keys
        .map((storeId) => _buildStatus(userId: userId, storeId: storeId))
        .where((status) => status.showInHistory)
        .toList()
      ..sort((a, b) => b.currentCount.compareTo(a.currentCount));
  }

  @override
  Future<StoreStampStatus> accrueStampForReview({
    required String userId,
    required String storeId,
  }) async {
    _ensureUserState(userId);

    final current = _buildStatus(userId: userId, storeId: storeId);
    if (!current.canWriteReview) {
      return current;
    }

    final nextCount = (current.currentCount + 1).clamp(0, current.goalCount);
    _stampCountsByUserId[userId]![storeId] = nextCount;
    _reviewedStoreIdsByUserId[userId]!.add(storeId);

    return _buildStatus(userId: userId, storeId: storeId);
  }

  @override
  Future<StoreStampStatus> revokeStampForDeletedReview({
    required String userId,
    required String storeId,
  }) async {
    _ensureUserState(userId);

    final current = _buildStatus(userId: userId, storeId: storeId);
    final nextCount = (current.currentCount - 1).clamp(0, current.goalCount);
    _stampCountsByUserId[userId]![storeId] = nextCount;
    _reviewedStoreIdsByUserId[userId]!.remove(storeId);

    return _buildStatus(userId: userId, storeId: storeId);
  }

  void _ensureUserState(String userId) {
    _stampCountsByUserId.putIfAbsent(
      userId,
      () => {
        's1': 3,
        's2': 0,
        's3': 0,
      },
    );
    _visitedStoreIdsByUserId.putIfAbsent(userId, () => {'s1', 's2'});
    _reviewedStoreIdsByUserId.putIfAbsent(userId, () => {'s1'});
  }

  StoreStampStatus _buildStatus({
    required String userId,
    required String storeId,
  }) {
    _ensureUserState(userId);

    final policy =
        _policies[storeId] ??
        StampRewardPolicy(
          storeId: storeId,
          storeName: storeId,
          goalCount: 10,
          rewardTitle: '사장님 지정 보상',
          rewardDescription: '스탬프 목표 달성 시 매장별 보상을 받을 수 있습니다.',
        );

    final currentCount = _stampCountsByUserId[userId]![storeId] ?? 0;
    final hasVisited = _visitedStoreIdsByUserId[userId]!.contains(storeId);
    final hasWrittenReview = _reviewedStoreIdsByUserId[userId]!.contains(
      storeId,
    );
    final canWriteReview = hasVisited && !hasWrittenReview;

    return StoreStampStatus(
      storeId: policy.storeId,
      storeName: policy.storeName,
      currentCount: currentCount,
      goalCount: policy.goalCount,
      rewardTitle: policy.rewardTitle,
      rewardDescription: policy.rewardDescription,
      canWriteReview: canWriteReview,
      reviewEligibilityMessage: _buildEligibilityMessage(
        hasVisited: hasVisited,
        hasWrittenReview: hasWrittenReview,
      ),
      showInHistory: hasVisited,
      historyStatusMessage: hasWrittenReview
          ? '이용 완료 · 리뷰 작성 완료'
          : '이용 완료 · 리뷰 미작성',
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
}
