class StampRewardPolicy {
  const StampRewardPolicy({
    required this.storeId,
    required this.storeName,
    required this.goalCount,
    required this.rewardTitle,
    required this.rewardDescription,
  });

  final String storeId;
  final String storeName;
  final int goalCount;
  final String rewardTitle;
  final String rewardDescription;
}
