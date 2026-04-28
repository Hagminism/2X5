import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_state.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:flutter/material.dart';

class ReviewHistoryViewModel extends ChangeNotifier {
  ReviewHistoryViewModel({
    required AuthRepository authRepository,
    required StoreReviewRepository storeReviewRepository,
  }) : _authRepository = authRepository,
       _storeReviewRepository = storeReviewRepository;

  final AuthRepository _authRepository;
  final StoreReviewRepository _storeReviewRepository;

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
}
