import 'package:capstone_2026/core/domain/model/store/store.dart';

abstract interface class StoreRepository {
  Future<Store?> getMyStore();

  Future<Store> createMyStore(Store store);

  Future<Store> updateMyStore(Store store);
}
