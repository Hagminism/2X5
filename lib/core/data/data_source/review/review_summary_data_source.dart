abstract interface class ReviewSummaryDataSource {
  Future<Map<String, dynamic>> summarizeStoreReviews({
    required String storeId,
    required String storeName,
    required String contentHash,
    required List<Map<String, dynamic>> reviews,
  });

  Future<void> invalidateStoreReviewSummary({
    required String storeId,
  });
}
