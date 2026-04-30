import 'package:capstone_2026/core/data/dto/store/store_dto.dart';

abstract interface class StoreDataSource {
  Future<StoreDto?> findStoreByOwnerId(String ownerId);

  Future<StoreDto> createStore(StoreDto storeDto);

  Future<StoreDto> updateStoreById(String id, StoreDto storeDto);
}
