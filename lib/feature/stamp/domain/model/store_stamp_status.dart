class StoreStampStatus {
  const StoreStampStatus({
    required this.storeId,
    required this.storeName,
    required this.currentCount,
    required this.goalCount,
    required this.rewardTitle,
    required this.rewardDescription,
    required this.canWriteReview,
    required this.reviewEligibilityMessage,
    required this.showInHistory,
    required this.historyStatusMessage,
    required this.hasWrittenReview,
  });

  final String storeId;
  final String storeName;
  final int currentCount;
  final int goalCount;
  final String rewardTitle;
  final String rewardDescription;
  final bool canWriteReview;
  final String reviewEligibilityMessage;
  final bool showInHistory;
  final String historyStatusMessage;
  final bool hasWrittenReview;

  bool get isRewardUnlocked => currentCount >= goalCount;

  double get progress {
    if (goalCount <= 0) {
      return 0;
    }
    final ratio = currentCount / goalCount;
    return ratio.clamp(0, 1).toDouble();
  }

  String get progressLabel => '$currentCount / $goalCount';

  StoreStampStatus copyWith({
    String? storeId,
    String? storeName,
    int? currentCount,
    int? goalCount,
    String? rewardTitle,
    String? rewardDescription,
    bool? canWriteReview,
    String? reviewEligibilityMessage,
    bool? showInHistory,
    String? historyStatusMessage,
    bool? hasWrittenReview,
  }) {
    return StoreStampStatus(
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      currentCount: currentCount ?? this.currentCount,
      goalCount: goalCount ?? this.goalCount,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      canWriteReview: canWriteReview ?? this.canWriteReview,
      reviewEligibilityMessage:
          reviewEligibilityMessage ?? this.reviewEligibilityMessage,
      showInHistory: showInHistory ?? this.showInHistory,
      historyStatusMessage: historyStatusMessage ?? this.historyStatusMessage,
      hasWrittenReview: hasWrittenReview ?? this.hasWrittenReview,
    );
  }
}
