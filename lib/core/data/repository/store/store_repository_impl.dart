import 'dart:math' as math;

import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/dto/store/store_dto.dart';
import 'package:capstone_2026/core/data/mapper/store/store_mapper.dart';
import 'package:capstone_2026/core/data/dto/store/store_layout_detail_dto.dart';
import 'package:capstone_2026/core/data/mapper/store/store_layout_detail_mapper.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_layout_detail.dart';
import 'package:capstone_2026/core/domain/model/store/store_list_entry.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/core/domain/validator/store_operating_hours_validator.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreDataSource _storeDataSource;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StoreOperatingHoursValidator _operatingHoursValidator;

  const StoreRepositoryImpl({
    required StoreDataSource storeDataSource,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required StoreOperatingHoursValidator operatingHoursValidator,
  }) : _storeDataSource = storeDataSource,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _operatingHoursValidator = operatingHoursValidator;

  @override
  Future<List<Store>> getStores() async {
    final storeDtos = await _storeDataSource.findStores();
    return storeDtos.map((storeDto) => storeDto.toModel()).toList();
  }

  @override
  Future<List<StoreListEntry>> findStoresNearWithCoverImages({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final latDelta = radiusMeters / 111000.0;
    final lngDelta =
        radiusMeters / (111000.0 * math.cos(latitude * math.pi / 180));

    final rows = await _storeDataSource.findStoresInBoundingBoxWithCoverImages(
      minLat: latitude - latDelta,
      maxLat: latitude + latDelta,
      minLng: longitude - lngDelta,
      maxLng: longitude + lngDelta,
    );
    return _mapRowsToStoreListEntries(rows);
  }

  @override
  Future<List<StoreListEntry>> findStoresPageWithCoverImages({
    required int from,
    required int to,
  }) async {
    final rows = await _storeDataSource.findStoresPageWithCoverImages(
      from: from,
      to: to,
    );
    return _mapRowsToStoreListEntries(rows);
  }

  List<StoreListEntry> _mapRowsToStoreListEntries(
    List<Map<String, dynamic>> rows,
  ) {
    return rows.map((json) {
      final storeDto = StoreDto.fromJson(json);
      return StoreListEntry(
        store: storeDto.toModel(),
        coverImageUrl: storeCoverImageUrlFromJsonRows(json['store_images']),
      );
    }).toList();
  }

  @override
  Future<Store?> findStoreById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final storeDto = await _storeDataSource.findStoreById(trimmedId);
    return storeDto?.toModel();
  }

  @override
  Future<Store?> getMyStore() async {
    final uid = _getCurrentUidOrThrow();
    final storeDto = await _storeDataSource.findStoreByOwnerId(uid);
    return storeDto?.toModel();
  }

  @override
  Future<Store> createMyStore(Store store) async {
    final uid = await _validateAndGetApprovedUid();
    _validateStoreInput(store);

    final createdStore = await _storeDataSource.createStore(
      store.copyWith(ownerId: uid).toDto(),
    );

    return createdStore.toModel();
  }

  @override
  Future<List<StoreImage>> getStoreImagesByStoreId(String storeId) {
    return _storeDataSource.findImagesByStoreId(storeId);
  }

  @override
  Future<Map<String, String?>> getCoverImageUrlsByStoreIds(
    List<String> storeIds,
  ) {
    return _storeDataSource.findCoverImageUrlsByStoreIds(storeIds);
  }

  @override
  Future<Store> updateMyStore(Store store) async {
    final uid = await _validateAndGetApprovedUid();
    _validateStoreInput(store);

    final existingStore = await _storeDataSource.findStoreByOwnerId(uid);
    if (existingStore == null) {
      throw StateError('수정할 업장 정보가 존재하지 않습니다.');
    }
    if ((existingStore.businessNumber ?? '').isNotEmpty &&
        existingStore.businessNumber != store.businessNumber) {
      throw StateError('사업자등록번호는 수정할 수 없습니다.');
    }

    final updateDto = store
        .copyWith(
          ownerId: uid,
          businessNumber: existingStore.businessNumber ?? store.businessNumber,
        )
        .toDto();

    final updatedStore = await _storeDataSource.updateStoreById(
      existingStore.id ?? store.id,
      updateDto,
    );

    return updatedStore.toModel();
  }

  @override
  Future<List<StoreMenu>> getStoreMenusByStoreId(String storeId) {
    return _storeDataSource.findMenusByStoreId(storeId);
  }

  @override
  Future<List<StoreMenu>> getMyStoreMenus() async {
    final store = await getMyStore();
    if (store == null) {
      return const [];
    }
    return _storeDataSource.findMenusByStoreId(store.id);
  }

  @override
  Future<List<StoreImage>> getMyStoreImages() async {
    final store = await getMyStore();
    if (store == null) {
      return const [];
    }
    return _storeDataSource.findImagesByStoreId(store.id);
  }

  @override
  Future<void> syncMyStoreMenus(List<StoreMenu> menus) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 메뉴를 설정할 수 있습니다.');
    }

    final normalizedMenus = List<StoreMenu>.generate(
      menus.length,
      (index) => menus[index].copyWith(sortOrder: index),
    );
    final existingMenus = await _storeDataSource.findMenusByStoreId(store.id);
    final existingById = {
      for (final menu in existingMenus)
        if (menu.id != null) menu.id!: menu,
    };
    final nextIds = <String>{};

    for (final menu in normalizedMenus) {
      _validateMenu(menu);
      if (menu.id == null || !existingById.containsKey(menu.id)) {
        await _storeDataSource.createMenu(store.id, menu);
      } else {
        nextIds.add(menu.id!);
        await _storeDataSource.updateMenuById(menu.id!, menu);
      }
    }

    final deletedIds = existingById.keys
        .where((id) => !nextIds.contains(id))
        .toList();
    await _storeDataSource.deleteMenusByIds(deletedIds);
  }

  @override
  Future<void> syncMyStoreImages(List<StoreImage> images) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 사진을 설정할 수 있습니다.');
    }

    final normalizedImages = List<StoreImage>.generate(
      images.length,
      (index) => images[index].copyWith(sortOrder: index),
    );
    _validateImages(normalizedImages);
    final existingImages = await _storeDataSource.findImagesByStoreId(store.id);
    final existingById = {
      for (final image in existingImages)
        if (image.id != null) image.id!: image,
    };
    final nextIds = <String>{};

    for (final image in normalizedImages) {
      if (image.id == null || !existingById.containsKey(image.id)) {
        await _storeDataSource.createImage(store.id, image);
      } else {
        nextIds.add(image.id!);
        await _storeDataSource.updateImageById(image.id!, image);
      }
    }

    final deletedIds = existingById.keys
        .where((id) => !nextIds.contains(id))
        .toList();
    await _storeDataSource.deleteImagesByIds(deletedIds);
  }

  @override
  Future<String> uploadMyStoreImageFile(String filePath) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 이미지를 업로드할 수 있습니다.');
    }
    return _storeDataSource.uploadStoreImageFile(
      storeId: store.id,
      filePath: filePath,
    );
  }

  @override
  Future<String> uploadMyStoreMenuImageFile(String filePath) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 메뉴 이미지를 업로드할 수 있습니다.');
    }
    return _storeDataSource.uploadStoreMenuImageFile(
      storeId: store.id,
      filePath: filePath,
    );
  }

  @override
  Future<String> uploadMySalonDesignerImageFile(String filePath) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 디자이너 이미지를 업로드할 수 있습니다.');
    }
    return _storeDataSource.uploadSalonDesignerImageFile(
      storeId: store.id,
      filePath: filePath,
    );
  }

  @override
  Future<void> deleteMyStoreMenuImageByUrl(String imageUrl) async {
    final store = await getMyStore();
    if (store == null) {
      return;
    }
    await _storeDataSource.deleteStoreMenuImageByUrl(
      storeId: store.id,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> deleteMySalonDesignerImageByUrl(String imageUrl) async {
    final store = await getMyStore();
    if (store == null) {
      return;
    }
    await _storeDataSource.deleteSalonDesignerImageByUrl(
      storeId: store.id,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<Store> getStoreById(String storeId) async {
    final storeDto = await _storeDataSource.findStoreById(storeId);

    if (storeDto == null) {
      throw StateError('해당 가게 정보를 찾을 수 없습니다. (ID: $storeId)');
    }

    return storeDto.toModel();
  }

  String _getCurrentUidOrThrow() {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('로그인 정보가 유효하지 않습니다.');
    }
    return uid;
  }

  Future<String> _validateAndGetApprovedUid() async {
    final uid = _getCurrentUidOrThrow();
    final user = await _userRepository.findUserById(uid);
    if (user?.partnerStatus != PartnerStatus.approved) {
      throw StateError('승인된 관리자만 업장 정보를 저장할 수 있습니다.');
    }
    return uid;
  }

  void _validateStoreInput(Store store) {
    if (store.name.trim().isEmpty ||
        store.category.trim().isEmpty ||
        store.businessNumber.trim().isEmpty ||
        store.address.trim().isEmpty ||
        store.contact.trim().isEmpty) {
      throw ArgumentError('업장 필수 입력값이 누락되었습니다.');
    }

    if (store.latitude.isNaN || store.longitude.isNaN) {
      throw ArgumentError('좌표 정보 형식이 올바르지 않습니다.');
    }

    final normalizedBusinessNumber = store.businessNumber.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (!RegExp(r'^\d{10}$').hasMatch(normalizedBusinessNumber)) {
      throw ArgumentError('사업자등록번호는 숫자 10자리여야 합니다.');
    }

    if (!_operatingHoursValidator.isValid(store.operatingHours)) {
      throw ArgumentError('운영시간 형식이 올바르지 않습니다.');
    }

    if (store.depositAmount < 0) {
      throw ArgumentError('예약금은 0원 이상이어야 합니다.');
    }
    if (!store.depositEnabled && store.depositAmount != 0) {
      throw ArgumentError('예약금을 사용하지 않으면 금액은 0원이어야 합니다.');
    }
    if (store.depositEnabled && store.depositAmount <= 0) {
      throw ArgumentError('예약금을 사용하면 금액은 0원보다 커야 합니다.');
    }
  }

  void _validateMenu(StoreMenu menu) {
    if (menu.name.trim().isEmpty) {
      throw ArgumentError('메뉴명은 필수입니다.');
    }
    if (menu.price < 0) {
      throw ArgumentError('메뉴 금액은 0원 이상이어야 합니다.');
    }
  }

  void _validateImages(List<StoreImage> images) {
    var coverCount = 0;
    for (final image in images) {
      if (image.imageUrl.trim().isEmpty) {
        throw ArgumentError('사진 URL은 비워둘 수 없습니다.');
      }
      if (image.isCover) {
        coverCount += 1;
      }
    }
    if (coverCount > 1) {
      throw ArgumentError('대표 사진은 1개만 설정할 수 있습니다.');
    }
  }

  @override
  Future<Store> createStoreDynamically(Store store) async {
    final createdStoreDto = await _storeDataSource.createStore(store.toDto());
    return createdStoreDto.toModel();
  }

  @override
  Future<void> addStoreImage(
    String storeId,
    String imageUrl, {
    bool isCover = false,
  }) async {
    final storeImage = StoreImage(
      id: null,
      imageUrl: imageUrl,
      caption: '',
      sortOrder: 0,
      isCover: isCover,
    );
    await _storeDataSource.createImage(storeId, storeImage);
  }

  @override
  Future<StoreLayoutDetail?> getStoreLayoutByStoreId(String storeId) async {
    final dto = await _storeDataSource.findLayoutByStoreId(storeId);
    return dto?.toModel();
  }

  @override
  Future<StoreLayoutDetail> saveMyStoreLayout(StoreLayoutDetail layout) async {
    final store = await getMyStore();
    if (store == null) {
      throw StateError('업장 정보 저장 후 내부 구조를 설정할 수 있습니다.');
    }

    final layoutDto = StoreLayoutDetailDto(
      id: layout.id.isEmpty ? null : layout.id,
      storeId: store.id,
      layoutJson: {
        'seats': layout.seats.map((seat) => seat.toJson()).toList(),
        'elements': layout.elements.map((element) => element.toJson()).toList(),
      },
    );

    final savedDto = await _storeDataSource.upsertLayout(layoutDto);
    return savedDto.toModel();
  }
}
