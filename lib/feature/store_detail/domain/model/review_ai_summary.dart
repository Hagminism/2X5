class ReviewAiSummary {
  const ReviewAiSummary({
    required this.oneLine,
    required this.keywords,
    required this.positiveRatio,
  });

  final String oneLine;
  final List<String> keywords;
  final double positiveRatio;
}
