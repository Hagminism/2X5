import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_list_entry.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';

abstract interface class StoreRepository {
  Future<List<Store>> getStores();

  /// 반경 [radiusMeters] bbox 조회 + cover 이미지 조인 (홈·거리순 클라이언트 페이징).
  Future<List<StoreListEntry>> findStoresNearWithCoverImages({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  /// GPS 없을 때 서버 range 페이지 + cover 이미지 조인.
  Future<List<StoreListEntry>> findStoresPageWithCoverImages({
    required int from,
    required int to,
  });

  Future<Store> getStoreById(String storeId);

  Future<Store?> findStoreById(String id);

  Future<Store?> getMyStore();

  Future<Store> createMyStore(Store store);

  Future<List<StoreImage>> getStoreImagesByStoreId(String storeId); //이미 조회

  Future<Map<String, String?>> getCoverImageUrlsByStoreIds(List<String> storeIds);

  Future<Store> updateMyStore(Store store);

  Future<List<StoreMenu>> getStoreMenusByStoreId(String storeId); //메뉴 조회

  Future<List<StoreMenu>> getMyStoreMenus();

  Future<List<StoreImage>> getMyStoreImages();

  Future<void> syncMyStoreMenus(List<StoreMenu> menus);

  Future<void> syncMyStoreImages(List<StoreImage> images);

  Future<String> uploadMyStoreImageFile(String filePath);

  Future<String> uploadMyStoreMenuImageFile(String filePath);

  Future<String> uploadMySalonDesignerImageFile(String filePath);

  Future<void> deleteMyStoreMenuImageByUrl(String imageUrl);

  Future<void> deleteMySalonDesignerImageByUrl(String imageUrl);

  Future<Store> createStoreDynamically(Store store);

  Future<void> addStoreImage(
    String storeId,
    String imageUrl, {
    bool isCover = false,
  });
}
