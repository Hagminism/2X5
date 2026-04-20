import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';

abstract interface class StoreReviewRepository {
  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  });

  Uri getGoogleMapSearchUri(String query);
}
