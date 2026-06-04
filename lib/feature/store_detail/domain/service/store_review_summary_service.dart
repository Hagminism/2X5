import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_summary_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';

class StoreReviewSummaryService {
  StoreReviewSummaryService({
    required StoreReviewService storeReviewService,
    required StoreReviewSummaryRepository storeReviewSummaryRepository,
  }) : _storeReviewService = storeReviewService,
       _storeReviewSummaryRepository = storeReviewSummaryRepository;

  static const int summaryReviewLimit = 50;

  final StoreReviewService _storeReviewService;
  final StoreReviewSummaryRepository _storeReviewSummaryRepository;

  List<ReviewSnippetInput> buildSnippets({
    required List<InternalReview> platformReviews,
    required List<Map<String, dynamic>> naverReviews,
    required List<GooglePlaceReview> googleReviews,
  }) {
    final snippets = <ReviewSnippetInput>[];

    for (final review in platformReviews) {
      final text = review.content.trim();
      if (text.isEmpty) {
        continue;
      }
      snippets.add(
        ReviewSnippetInput(
          source: ReviewSnippetSource.platform,
          text: _truncate(text),
          rating: review.rating,
          visitPurpose: review.visitPurpose,
        ),
      );
    }

    for (final review in naverReviews) {
      final text = (review['body'] as String? ?? '').trim();
      if (text.isEmpty) {
        continue;
      }
      snippets.add(
        ReviewSnippetInput(
          source: ReviewSnippetSource.naver,
          text: _truncate(text),
        ),
      );
    }

    for (final review in googleReviews) {
      final text = review.text.trim();
      if (text.isEmpty) {
        continue;
      }
      snippets.add(
        ReviewSnippetInput(
          source: ReviewSnippetSource.google,
          text: _truncate(text),
          rating: review.rating,
        ),
      );
    }

    return snippets;
  }

  Future<ReviewAiSummary> summarize({
    required String storeId,
    required String storeName,
    required List<InternalReview> platformReviews,
    required List<Map<String, dynamic>> naverReviews,
    required List<GooglePlaceReview> googleReviews,
  }) {
    final snippets = buildSnippets(
      platformReviews: platformReviews,
      naverReviews: naverReviews,
      googleReviews: googleReviews,
    );

    return _storeReviewSummaryRepository.summarizeStoreReviews(
      storeId: storeId,
      storeName: storeName,
      snippets: snippets,
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
  }) {
    return _storeReviewSummaryRepository.invalidateStoreReviewSummary(
      storeId: storeId,
    );
  }

  String _truncate(String value) {
    const maxLength = 300;
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}…';
  }
}
