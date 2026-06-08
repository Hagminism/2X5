import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/review_ai_summary_generator.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';

class StoreReviewSummaryService {
  StoreReviewSummaryService({
    required StoreReviewService storeReviewService,
  }) : _storeReviewService = storeReviewService;

  static const int summaryReviewLimit = 50;

  final StoreReviewService _storeReviewService;

  Future<ReviewAiSummary> summarize({
    required String storeName,
    required List<InternalReview> platformReviews,
    required List<Map<String, dynamic>> naverReviews,
    required List<GooglePlaceReview> googleReviews,
  }) {
    return Future.value(
      ReviewAiSummaryGenerator.generate(
        storeName: storeName,
        reviews: platformReviews,
        naverReviews: naverReviews,
        googleReviews: googleReviews,
      ),
    );
  }

  Future<List<InternalReview>> loadPlatformReviewsForSummary({
    required String storeId,
  }) {
    return _storeReviewService.loadStoreReviews(
      storeId: storeId,
      limit: summaryReviewLimit,
    );
  }

  Future<void> invalidateSummary({
    required String storeId,
  }) async {}
}
