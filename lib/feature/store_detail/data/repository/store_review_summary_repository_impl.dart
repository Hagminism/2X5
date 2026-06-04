import 'package:capstone_2026/core/data/data_source/review/review_summary_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_summary_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/util/review_summary_content_hash.dart';
import 'package:capstone_2026/feature/store_detail/domain/util/review_summary_snippet_normalizer.dart';

class StoreReviewSummaryRepositoryImpl implements StoreReviewSummaryRepository {
  StoreReviewSummaryRepositoryImpl({
    required ReviewSummaryDataSource reviewSummaryDataSource,
  }) : _reviewSummaryDataSource = reviewSummaryDataSource;

  final ReviewSummaryDataSource _reviewSummaryDataSource;

  @override
  Future<ReviewAiSummary> summarizeStoreReviews({
    required String storeId,
    required String storeName,
    required List<ReviewSnippetInput> snippets,
  }) async {
    final normalizedSnippets = normalizeReviewSnippetsForSummary(snippets);
    if (normalizedSnippets.isEmpty) {
      return ReviewAiSummary.empty(storeName: storeName);
    }

    final contentHash = computeReviewSummaryContentHash(normalizedSnippets);
    final response = await _reviewSummaryDataSource.summarizeStoreReviews(
      storeId: storeId,
      storeName: storeName,
      contentHash: contentHash,
      reviews: normalizedSnippets.map((snippet) => snippet.toJson()).toList(),
    );

    final summaryRaw = response['summary'];
    if (summaryRaw is! Map) {
      throw StateError('요약 응답 형식이 올바르지 않습니다.');
    }

    final summaryMap = Map<String, dynamic>.from(summaryRaw);
    final oneLine = summaryMap['oneLine']?.toString().trim() ?? '';
    final keywordsRaw = summaryMap['keywords'];
    final keywords = keywordsRaw is List
        ? keywordsRaw
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .take(3)
              .toList()
        : <String>[];
    final positiveRatio = (summaryMap['positiveRatio'] as num?)?.toDouble();

    final reviewCountsRaw = response['reviewCounts'];
    final reviewCounts = reviewCountsRaw is Map
        ? ReviewSummaryCounts.fromJson(Map<String, dynamic>.from(reviewCountsRaw))
        : ReviewSummaryCounts.fromSnippets(normalizedSnippets);

    if (oneLine.isEmpty) {
      throw StateError('요약 문장을 생성하지 못했습니다.');
    }

    return ReviewAiSummary(
      oneLine: oneLine,
      keywords: keywords.isEmpty
          ? const ['방문 후기', '서비스', '분위기']
          : keywords,
      positiveRatio: positiveRatio ?? 0,
      reviewCounts: reviewCounts,
    );
  }

  @override
  Future<void> invalidateStoreReviewSummary({
    required String storeId,
  }) {
    return _reviewSummaryDataSource.invalidateStoreReviewSummary(
      storeId: storeId,
    );
  }
}
