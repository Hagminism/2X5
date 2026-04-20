import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';

abstract interface class StoreDetailRepository {
  StoreDetail getStoreDetailById(String storeId);
}
