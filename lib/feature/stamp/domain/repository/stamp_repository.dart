import 'package:capstone_2026/feature/stamp/domain/model/stamp_reward_policy.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';

abstract interface class StampRepository {
  Future<StoreStampStatus> fetchStoreStampStatus({
    required String userId,
    required String storeId,
  });

  Future<List<StoreStampStatus>> fetchUserStampStatuses({
    required String userId,
  });

  Future<StoreStampStatus> accrueStampForReview({
    required String userId,
    required String storeId,
  });

  Future<StoreStampStatus> revokeStampForDeletedReview({
    required String userId,
    required String storeId,
  });

  Future<StoreStampStatus> claimReward({
    required String userId,
    required String storeId,
  });

  Future<StampRewardPolicy?> fetchStampRewardPolicy({
    required String storeId,
  });

  Future<void> saveStampRewardPolicy({
    required String storeId,
    required int goalCount,
    required String rewardTitle,
    required String rewardDescription,
    required bool isActive,
  });
}
