import 'package:capstone_2026/feature/store_detail/domain/model/review_snippet_input.dart';

class ReviewSummaryCounts {
  const ReviewSummaryCounts({
    required this.internal,
    required this.naver,
    required this.google,
  });

  final int internal;
  final int naver;
  final int google;

  factory ReviewSummaryCounts.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryCounts(
      internal: (json['internal'] as num?)?.toInt() ?? 0,
      naver: (json['naver'] as num?)?.toInt() ?? 0,
      google: (json['google'] as num?)?.toInt() ?? 0,
    );
  }

  factory ReviewSummaryCounts.fromSnippets(List<ReviewSnippetInput> snippets) {
    var internal = 0;
    var naver = 0;
    var google = 0;
    for (final snippet in snippets) {
      switch (snippet.source) {
        case ReviewSnippetSource.platform:
          internal++;
        case ReviewSnippetSource.naver:
          naver++;
        case ReviewSnippetSource.google:
          google++;
      }
    }
    return ReviewSummaryCounts(
      internal: internal,
      naver: naver,
      google: google,
    );
  }

  int get total => internal + naver + google;

  String toCaption() {
    return '플랫폼 $internal · 네이버 $naver · 구글 $google건 기준';
  }
}

class ReviewAiSummary {
  const ReviewAiSummary({
    required this.oneLine,
    required this.keywords,
    required this.positiveRatio,
    this.reviewCounts,
  });

  final String oneLine;
  final List<String> keywords;
  final double positiveRatio;
  final ReviewSummaryCounts? reviewCounts;

  bool get hasPositiveRatio => positiveRatio > 0;

  factory ReviewAiSummary.empty({required String storeName}) {
    return ReviewAiSummary(
      oneLine:
          '$storeName은(는) 아직 등록된 리뷰가 많지 않아, '
          '리뷰가 쌓이면 방문 후기를 요약해 보여드릴 예정입니다.',
      keywords: const ['방문 후기', '리뷰', '매장 평가'],
      positiveRatio: 0,
    );
  }
}
