import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_state.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ReviewHistoryViewModel extends ChangeNotifier {
  ReviewHistoryViewModel({
    required AuthRepository authRepository,
    required StoreReviewRepository storeReviewRepository,
    required StampService stampService,
  }) : _authRepository = authRepository,
       _storeReviewRepository = storeReviewRepository,
       _stampService = stampService;

  final AuthRepository _authRepository;
  final StoreReviewRepository _storeReviewRepository;
  final StampService _stampService;

  ReviewHistoryState _state = const ReviewHistoryState();

  ReviewHistoryState get state => _state;

  Future<void> fetchReviews() async {
    if (state.isLoading) return;

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      _state = state.copyWith(reviews: const []);
      notifyListeners();
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final reviews = await _storeReviewRepository.fetchUserReviews(
      userId: user.uid,
    );

    _state = state.copyWith(
      isLoading: false,
      reviews: reviews,
    );
    notifyListeners();
  }

  Future<void> updateReview({
    required InternalReview currentReview,
    required ReviewWriteResult result,
  }) async {
    final updatedReview = await _storeReviewRepository.updateReview(
      reviewId: currentReview.id,
      review: result,
    );

    final updatedReviews = state.reviews
        .map((review) => review.id == updatedReview.id ? updatedReview : review)
        .toList();

    _state = state.copyWith(reviews: updatedReviews);
    notifyListeners();
  }

  Future<void> deleteReview({
    required InternalReview review,
  }) async {
    await _storeReviewRepository.deleteReview(reviewId: review.id);
    await _stampService.revokeStampForDeletedReview(storeId: review.storeId);

    final remainingReviews = state.reviews
        .where((item) => item.id != review.id)
        .toList();

    _state = state.copyWith(reviews: remainingReviews);
    notifyListeners();
  }
}
