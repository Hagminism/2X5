import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';

class ReviewAiSummaryGenerator {
  // ... (rules and phrases omitted for brevity in replacement instruction, I will include them in actual tool call)
  static const Map<String, List<String>> _keywordRules = {
    '친절한 응대': ['친절', '응대', '서비스', '상담', '설명', '직원분'],
    '고기 맛집': ['고기', '육즙', '구워', '맛있', '신선한 고기'],
    '반찬 구성이 좋음': ['반찬', '백김치', '양배추', '무말랭이', '쌈'],
    '메뉴 만족도': ['맛', '커피', '디저트', '메뉴', '음식', '국수'],
    '쾌적한 분위기': ['분위기', '조용', '깔끔', '쾌적', '편안', '창문', '창가'],
    '단체 방문': ['회식', '단체', '모임', '친구들'],
    '데이트 코스': ['데이트', '소개팅', '연인', '분위기'],
    '가족 외식': ['가족', '아이', '부모님', '생일'],
    '콜키지 장점': ['콜키지', '와인'],
    '빠른 방문': ['빠른', '간단', '가볍게'],
    '맞춤 상담': ['스타일', '디자이너', '컷', '상담', '컬러'],
  };

  static const List<String> _positiveKeywords = [
    '좋',
    '추천',
    '친절',
    '만족',
    '깔끔',
    '쾌적',
    '재방문',
    '편하',
    '맛있',
    '최고',
  ];

  static const List<String> _negativeKeywords = [
    '별로',
    '아쉽',
    '불친절',
    '시끄럽',
    '짜증',
    '불편',
    '실망',
  ];

  static const Map<String, _SummaryPhrase> _phrases = {
    '친절한 응대': _SummaryPhrase(
      label: '친절한 응대',
      single: '응대가 친절한',
      pair: '응대가 친절하고',
    ),
    '고기 맛집': _SummaryPhrase(
      label: '고기 맛집',
      single: '고기 맛이 좋은',
      pair: '고기 맛이 좋고',
    ),
    '반찬 구성이 좋음': _SummaryPhrase(
      label: '반찬 구성이 좋음',
      single: '반찬 구성이 만족스러운',
      pair: '반찬 구성이 만족스럽고',
    ),
    '메뉴 만족도': _SummaryPhrase(
      label: '메뉴 만족도',
      single: '메뉴 만족도가 높은',
      pair: '메뉴 만족도가 높고',
    ),
    '쾌적한 분위기': _SummaryPhrase(
      label: '쾌적한 분위기',
      single: '분위기가 편안한',
      pair: '분위기가 편안하고',
    ),
    '단체 방문': _SummaryPhrase(
      label: '단체 방문',
      single: '단체로 방문하기 좋은',
      pair: '단체로 방문하기 좋고',
    ),
    '데이트 코스': _SummaryPhrase(
      label: '데이트 코스',
      single: '데이트하기 좋은',
      pair: '데이트하기 좋고',
    ),
    '가족 외식': _SummaryPhrase(
      label: '가족 외식',
      single: '가족끼리 식사하기 좋은',
      pair: '가족끼리 식사하기 좋고',
    ),
    '콜키지 장점': _SummaryPhrase(
      label: '콜키지 장점',
      single: '콜키지 이용이 편한',
      pair: '콜키지 이용이 편하고',
    ),
    '빠른 방문': _SummaryPhrase(
      label: '빠른 방문',
      single: '가볍게 들르기 좋은',
      pair: '가볍게 들르기 좋고',
    ),
    '맞춤 상담': _SummaryPhrase(
      label: '맞춤 상담',
      single: '상담이 꼼꼼한',
      pair: '상담이 꼼꼼하고',
    ),
  };

  static ReviewAiSummary generate({
    required String storeName,
    required List<InternalReview> reviews,
    List<GooglePlaceReview> googleReviews = const [],
  }) {
    if (reviews.isEmpty && googleReviews.isEmpty) {
      return const ReviewAiSummary(
        oneLine: '아직 등록된 리뷰가 많지 않아, 리뷰가 쌓이면 매장의 특징을 더 정확하게 요약해 보여줄 예정입니다.',
        keywords: ['자체 리뷰', '방문 후기', '스탬프 적립'],
        positiveRatio: 0.92,
      );
    }

    // 모든 리뷰를 동일한 비중으로 통합 분석
    const double weight = 1.0;

    final keywordScores = <String, double>{
      for (final label in _keywordRules.keys) label: 0,
    };

    var positiveSignals = 0.0;
    var negativeSignals = 0.0;
    double ratingTotal = 0.0;

    // 자체 리뷰 분석
    for (final review in reviews) {
      final normalized = review.content.toLowerCase();
      ratingTotal += review.rating * weight;

      for (final keyword in _positiveKeywords) {
        if (normalized.contains(keyword)) {
          positiveSignals += weight;
        }
      }

      for (final keyword in _negativeKeywords) {
        if (normalized.contains(keyword)) {
          negativeSignals += weight;
        }
      }

      final visitPurpose = review.visitPurpose?.trim();
      if (visitPurpose != null && visitPurpose.isNotEmpty) {
        final mappedPurpose = _mapVisitPurpose(visitPurpose);
        keywordScores[mappedPurpose] =
            (keywordScores[mappedPurpose] ?? 0) + (2 * weight);
      }

      for (final entry in _keywordRules.entries) {
        for (final keyword in entry.value) {
          if (normalized.contains(keyword)) {
            keywordScores[entry.key] =
                (keywordScores[entry.key] ?? 0) + (1 * weight);
          }
        }
      }
    }

    // Google 리뷰 분석
    for (final review in googleReviews) {
      final normalized = review.text.toLowerCase();
      if (review.rating != null) {
        ratingTotal += review.rating! * weight;
      }

      for (final keyword in _positiveKeywords) {
        if (normalized.contains(keyword)) {
          positiveSignals += weight;
        }
      }

      for (final keyword in _negativeKeywords) {
        if (normalized.contains(keyword)) {
          negativeSignals += weight;
        }
      }

      for (final entry in _keywordRules.entries) {
        for (final keyword in entry.value) {
          if (normalized.contains(keyword)) {
            keywordScores[entry.key] =
                (keywordScores[entry.key] ?? 0) + (1 * weight);
          }
        }
      }
    }

    final selectedKeywords = keywordScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final keywords = selectedKeywords
        .where((entry) => entry.value > 0)
        .take(3)
        .map((entry) => entry.key)
        .toList();

    if (keywords.isEmpty) {
      keywords.addAll(const ['방문 후기', '서비스 만족', '재방문 의사']);
    }

    // 평균 별점 및 긍정 비율 계산
    final int googleRatingCount =
        googleReviews.where((r) => r.rating != null).length;
    final double divisor = (reviews.length + googleRatingCount) * weight;
    final averageRating = divisor > 0 ? (ratingTotal / divisor) : 0.0;
    final ratingScore = averageRating / 5;
    final sentimentTotal = positiveSignals + negativeSignals;
    final sentimentScore =
        sentimentTotal == 0 ? 0.9 : positiveSignals / sentimentTotal;

    final positiveRatio = (ratingScore * 0.7 + sentimentScore * 0.3).clamp(
      0.05,
      0.99,
    );

    return ReviewAiSummary(
      oneLine: _buildCombinedOneLine(
        storeName: storeName,
        keywords: keywords,
      ),
      keywords: keywords,
      positiveRatio: positiveRatio,
    );
  }

  static String _mapVisitPurpose(String visitPurpose) {
    final normalized = visitPurpose.trim().toLowerCase();

    if (normalized.contains('혼밥') ||
        normalized.contains('빠른') ||
        normalized.contains('간단')) {
      return '빠른 방문';
    }

    if (normalized.contains('데이트') ||
        normalized.contains('소개팅') ||
        normalized.contains('연인')) {
      return '데이트 코스';
    }

    if (normalized.contains('모임') ||
        normalized.contains('회식') ||
        normalized.contains('친구') ||
        normalized.contains('단체')) {
      return '단체 방문';
    }

    if (normalized.contains('가족') ||
        normalized.contains('부모님') ||
        normalized.contains('생일') ||
        normalized.contains('아이')) {
      return '가족 외식';
    }

    return visitPurpose;
  }

  static String _buildCombinedOneLine({
    required String storeName,
    required List<String> keywords,
  }) {
    final first = keywords.isNotEmpty ? keywords[0] : '방문 후기';
    final second = keywords.length > 1 ? keywords[1] : null;

    if (first == '고기 맛집' && second == '반찬 구성이 좋음') {
      return '$storeName은 고기 맛이 좋고 반찬 구성도 만족스러운 매장입니다.';
    }

    if (first == '단체 방문' && second == '가족 외식') {
      return '$storeName은 단체 방문과 가족끼리 식사하기 좋은 매장입니다.';
    }

    if (first == '친절한 응대' && second == '맞춤 상담') {
      return '$storeName은 응대가 친절하고 상담이 꼼꼼한 매장입니다.';
    }

    if (first == '데이트 코스' && second == '쾌적한 분위기') {
      return '$storeName은 데이트하기 좋고 분위기가 편안한 매장입니다.';
    }

    if (first == '빠른 방문' && second == '메뉴 만족도') {
      return '$storeName은 가볍게 들르기 좋고 메뉴 만족도가 높은 매장입니다.';
    }

    if (first == '가족 외식' && second == '콜키지 장점') {
      return '$storeName은 가족 외식에 어울리고 콜키지 이용도 편한 매장입니다.';
    }

    if (second == null) {
      return '$storeName은 ${_toSingleSentence(first)} 매장입니다.';
    }

    return '$storeName은 ${_toPairSentence(first, second)} 매장입니다.';
  }

  static String _toSingleSentence(String keyword) {
    return _phrases[keyword]?.single ?? '$keyword 평가가 좋은';
  }

  static String _toPairSentence(String first, String second) {
    final firstPhrase = _phrases[first];
    final secondPhrase = _phrases[second];

    if (firstPhrase == null || secondPhrase == null) {
      return '$first과 $second 모두 만족도가 높은';
    }

    return '${firstPhrase.pair} ${secondPhrase.single}';
  }
}

class _SummaryPhrase {
  const _SummaryPhrase({
    required this.label,
    required this.single,
    required this.pair,
  });

  final String label;
  final String single;
  final String pair;
}
