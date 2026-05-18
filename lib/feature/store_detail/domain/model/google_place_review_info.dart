class GooglePlaceReviewInfo {
  const GooglePlaceReviewInfo({
    required this.placeId,
    required this.googleMapsUri,
    this.displayName,
    this.rating,
    this.userRatingCount,
    this.reviewSummary,
    this.reviews = const [],
  });

  final String placeId;
  final Uri? googleMapsUri;
  final String? displayName;
  final double? rating;
  final int? userRatingCount;
  final String? reviewSummary;
  final List<GooglePlaceReview> reviews;

  bool get hasSummary => reviewSummary?.trim().isNotEmpty == true;
}

class GooglePlaceReview {
  const GooglePlaceReview({
    required this.text,
    this.rating,
    this.authorName,
  });

  final String text;
  final double? rating;
  final String? authorName;
}
