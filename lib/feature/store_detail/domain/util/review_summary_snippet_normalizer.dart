import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';

const int reviewSummaryMaxTextLength = 300;
const int reviewSummaryMaxReviewsPerSource = 50;

/// 서버 `normalizeReviews`와 동일한 규칙으로 스니펫을 정규화한다.
List<ReviewSnippetInput> normalizeReviewSnippetsForSummary(
  List<ReviewSnippetInput> snippets,
) {
  final platform = <ReviewSnippetInput>[];
  final naver = <ReviewSnippetInput>[];
  final google = <ReviewSnippetInput>[];

  for (final snippet in snippets) {
    final text = _truncateForSummary(snippet.text.trim());
    if (text.isEmpty) {
      continue;
    }

    final normalized = ReviewSnippetInput(
      source: snippet.source,
      text: text,
      rating: snippet.rating,
      visitPurpose: snippet.visitPurpose?.trim(),
    );

    switch (snippet.source) {
      case ReviewSnippetSource.platform:
        platform.add(normalized);
      case ReviewSnippetSource.naver:
        naver.add(normalized);
      case ReviewSnippetSource.google:
        google.add(normalized);
    }
  }

  return [
    ...platform.take(reviewSummaryMaxReviewsPerSource),
    ...naver.take(reviewSummaryMaxReviewsPerSource),
    ...google.take(reviewSummaryMaxReviewsPerSource),
  ];
}

/// 서버 `formatRatingForHash`와 동일하게 별점을 해시용 문자열로 만든다.
String formatRatingForHash(double? rating) {
  if (rating == null) {
    return '';
  }
  final rounded = rating.roundToDouble();
  if (rating == rounded) {
    return rounded.toInt().toString();
  }
  return rating.toString();
}

String _truncateForSummary(String value) {
  if (value.length <= reviewSummaryMaxTextLength) {
    return value;
  }
  return '${value.substring(0, reviewSummaryMaxTextLength)}…';
}
