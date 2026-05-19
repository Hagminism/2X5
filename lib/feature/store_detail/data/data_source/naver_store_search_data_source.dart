import 'package:capstone_2026/feature/store_detail/data/model/naver_store_info.dart';

abstract interface class NaverStoreSearchDataSource {
  Future<NaverStoreInfo?> fetchExactStoreInfo({
    required String storeName,
    required String location,
  });

  Future<List<Map<String, dynamic>>> searchStoresByKeyword({
    required String keyword,
    int display = 10,
  });

  Future<String?> fetchStoreImageUrl({
    required String storeName,
    required String address,
  });

  Future<Map<String, String?>?> fetchPlaceInfoFromMobileSearch({
    required String storeName,
  });

  Future<Map<String, dynamic>?> fetchPlaceSummary({
    required String placeId,
  });
}
