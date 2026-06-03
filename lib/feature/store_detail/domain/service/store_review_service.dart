import 'package:capstone_2026/core/domain/model/review/review_reservation_ref.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
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
    ReviewReservationRef? reservationRef,
  }) {
    return _storeReviewRepository.submitReview(
      storeId: storeId,
      storeName: storeName,
      userId: _authRepository.getCurrentUserId(),
      userName: _authRepository.getCurrentUserDisplayName(),
      review: review,
      reservationRef: reservationRef,
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

  Future<GooglePlaceReviewInfo?> fetchGooglePlaceReviewInfo({
    required String storeName,
    required String location,
  }) {
    return _storeReviewRepository.fetchGooglePlaceReviewInfo(
      storeName: storeName,
      location: location,
    );
  }
}
