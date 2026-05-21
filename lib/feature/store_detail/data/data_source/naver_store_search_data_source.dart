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

  /// 프록시 `/api/place/{placeId}/hours` — `weeklyHours`, `statusDescription`.
  Future<Map<String, dynamic>?> fetchPlaceOperatingHours({
    required String placeId,
  });

  Future<List<Map<String, dynamic>>> fetchStoreMenus({
    required String placeId,
  });

  Future<List<Map<String, dynamic>>> fetchStoreReviews({
    required String placeId,
    int page = 1,
    int size = 15,
    String? after,
  });
}

