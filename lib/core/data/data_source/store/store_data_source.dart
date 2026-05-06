import 'package:capstone_2026/core/data/dto/store/store_dto.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';

abstract interface class StoreDataSource {
  Future<StoreDto?> findStoreByOwnerId(String ownerId);

  Future<StoreDto> createStore(StoreDto storeDto);

  Future<StoreDto> updateStoreById(String id, StoreDto storeDto);

  Future<List<StoreMenu>> findMenusByStoreId(String storeId);

  Future<List<StoreImage>> findImagesByStoreId(String storeId);

  Future<StoreMenu> createMenu(String storeId, StoreMenu menu);

  Future<StoreImage> createImage(String storeId, StoreImage image);

  Future<StoreMenu> updateMenuById(String id, StoreMenu menu);

  Future<StoreImage> updateImageById(String id, StoreImage image);

  Future<void> deleteMenusByIds(List<String> ids);

  Future<void> deleteImagesByIds(List<String> ids);

  Future<String> uploadImageFile({
    required String storeId,
    required String filePath,
  });
}
