import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';

class ReviewHistoryState {
  const ReviewHistoryState({
    this.isLoading = false,
    this.reviews = const [],
  });

  final bool isLoading;
  final List<InternalReview> reviews;

  ReviewHistoryState copyWith({
    bool? isLoading,
    List<InternalReview>? reviews,
  }) {
    return ReviewHistoryState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
    );
  }
}
