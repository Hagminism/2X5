import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';

abstract interface class StoreReviewRepository {
  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  });

  Uri getGoogleMapSearchUri(String query);

  Future<GooglePlaceReviewInfo?> fetchGooglePlaceReviewInfo({
    required String storeName,
    required String location,
  });

  Future<List<InternalReview>> fetchStoreReviews({
    required String storeId,
    int limit = 20,
  });

  Future<List<InternalReview>> fetchUserReviews({
    required String userId,
    int limit = 20,
  });

  Future<InternalReview> submitReview({
    required String storeId,
    required String storeName,
    required String userId,
    required String userName,
    required ReviewWriteResult review,
  });

  Future<InternalReview> updateReview({
    required String reviewId,
    required ReviewWriteResult review,
  });

  Future<void> deleteReview({
    required String reviewId,
  });
}
