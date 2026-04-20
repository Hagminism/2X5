import 'package:capstone_2026/feature/store_detail/data/mocks/store_detail_mock_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';

class MockStoreDetailRepositoryImpl implements StoreDetailRepository {
  @override
  StoreDetailData getStoreDetailById(String storeId) {
    return storeData[storeId] ?? defaultStoreData;
  }
}
