abstract interface class ReviewImageDataSource {
  Future<List<String>> uploadReviewImages({
    required String userId,
    required List<String> filePaths,
  });

  Future<void> deleteReviewImagesByPublicUrls({
    required List<String> publicUrls,
  });
}
