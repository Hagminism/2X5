import 'package:capstone_2026/feature/store_detail/data/mocks/store_detail_mock_data.dart';

abstract interface class StoreDetailRepository {
  StoreDetailData getStoreDetailById(String storeId);
}
