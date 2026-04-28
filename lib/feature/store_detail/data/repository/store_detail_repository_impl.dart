import 'package:capstone_2026/feature/store_detail/data/store_detail_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';

class MockStoreDetailRepositoryImpl implements StoreDetailRepository {
  @override
  StoreDetail getStoreDetailById(String storeId) {
    return storeDetailMockMap[storeId] ?? defaultStoreDetail;
  }
}
