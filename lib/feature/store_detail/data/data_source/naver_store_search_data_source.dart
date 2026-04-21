import 'package:capstone_2026/feature/store_detail/data/model/naver_store_info.dart';

abstract interface class NaverStoreSearchDataSource {
  Future<NaverStoreInfo?> fetchExactStoreInfo({
    required String storeName,
    required String location,
  });
}
