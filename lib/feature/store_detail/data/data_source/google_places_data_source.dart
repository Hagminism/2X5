import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';

abstract interface class GooglePlacesDataSource {
  Future<GooglePlaceReviewInfo?> fetchReviewInfo({
    required String storeName,
    required String location,
  });
}
