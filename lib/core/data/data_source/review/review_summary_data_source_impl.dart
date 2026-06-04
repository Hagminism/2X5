import 'package:capstone_2026/core/data/data_source/review/review_summary_data_source.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ReviewSummaryDataSourceImpl implements ReviewSummaryDataSource {
  ReviewSummaryDataSourceImpl({
    required FirebaseFunctions firebaseFunctions,
  }) : _firebaseFunctions = firebaseFunctions;

  final FirebaseFunctions _firebaseFunctions;

  @override
  Future<Map<String, dynamic>> summarizeStoreReviews({
    required String storeId,
    required String storeName,
    required String contentHash,
    required List<Map<String, dynamic>> reviews,
  }) async {
    final callable = _firebaseFunctions.httpsCallable('summarizeStoreReviews');
    final response = await callable.call({
      'storeId': storeId,
      'storeName': storeName,
      'contentHash': contentHash,
      'reviews': reviews,
    });
    final data = response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw StateError('요약 응답 형식이 올바르지 않습니다.');
  }

  @override
  Future<void> invalidateStoreReviewSummary({
    required String storeId,
  }) async {
    final callable =
        _firebaseFunctions.httpsCallable('invalidateStoreReviewSummary');
    await callable.call({'storeId': storeId});
  }
}
