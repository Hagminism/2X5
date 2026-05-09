import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';

abstract interface class StoreRepository {
  Future<List<Store>> getStores();

  Future<Store?> getStoreById(String storeId);

  Future<Store?> getMyStore();

  Future<Store> createMyStore(Store store);

  Future<Store> updateMyStore(Store store);

  Future<List<StoreMenu>> getMyStoreMenus();

  Future<List<StoreImage>> getMyStoreImages();

  Future<void> syncMyStoreMenus(List<StoreMenu> menus);

  Future<void> syncMyStoreImages(List<StoreImage> images);

  Future<String> uploadMyStoreImageFile(String filePath);

  Future<String> uploadMyStoreMenuImageFile(String filePath);

  Future<void> deleteMyStoreMenuImageByUrl(String imageUrl);
}
