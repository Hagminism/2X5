import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';

abstract interface class StoreReviewSummaryRepository {
  Future<ReviewAiSummary> summarizeStoreReviews({
    required String storeId,
    required String storeName,
    required List<ReviewSnippetInput> snippets,
  });

  Future<void> invalidateStoreReviewSummary({
    required String storeId,
  });
}
