import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';

abstract interface class StoreReviewRepository {
  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  });

  Uri getGoogleMapSearchUri(String query);

  Future<List<InternalReview>> fetchStoreReviews({
    required String storeId,
    int limit = 20,
  });

  Future<List<InternalReview>> fetchUserReviews({
    required String userId,
    int limit = 20,
  });
}
