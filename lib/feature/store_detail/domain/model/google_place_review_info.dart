class GooglePlaceReviewInfo {
  const GooglePlaceReviewInfo({
    required this.placeId,
    required this.googleMapsUri,
    this.rating,
    this.userRatingCount,
    this.reviewSummary,
  });

  final String placeId;
  final Uri? googleMapsUri;
  final double? rating;
  final int? userRatingCount;
  final String? reviewSummary;

  bool get hasSummary => reviewSummary?.trim().isNotEmpty == true;
}
