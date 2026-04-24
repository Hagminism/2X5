import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';

class StoreReviewService {
  StoreReviewService({
    required StoreReviewRepository storeReviewRepository,
    required AuthRepository authRepository,
  }) : _storeReviewRepository = storeReviewRepository,
       _authRepository = authRepository;

  final StoreReviewRepository _storeReviewRepository;
  final AuthRepository _authRepository;

  Future<List<InternalReview>> loadStoreReviews({
    required String storeId,
    int limit = 20,
  }) {
    return _storeReviewRepository.fetchStoreReviews(
      storeId: storeId,
      limit: limit,
    );
  }

  Future<InternalReview> submitReview({
    required String storeId,
    required String storeName,
    required ReviewWriteResult review,
  }) {
    return _storeReviewRepository.submitReview(
      storeId: storeId,
      storeName: storeName,
      userId: _authRepository.getCurrentUserId(),
      userName: _authRepository.getCurrentUserDisplayName(),
      review: review,
    );
  }

  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  }) {
    return _storeReviewRepository.getNaverReviewLinkTarget(
      storeName: storeName,
      location: location,
      placeId: placeId,
    );
  }

  Uri getGoogleMapSearchUri(String query) {
    return _storeReviewRepository.getGoogleMapSearchUri(query);
  }
}
