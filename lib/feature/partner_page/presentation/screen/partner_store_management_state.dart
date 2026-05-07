import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_management_state.freezed.dart';

const _defaultOperatingHours = <String, Map<String, dynamic>>{
  'monday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'tuesday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'wednesday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'thursday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'friday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'saturday': {'isOpened': true, 'openTime': null, 'closeTime': null},
  'sunday': {'isOpened': true, 'openTime': null, 'closeTime': null},
};

@freezed
abstract class PartnerStoreManagementState with _$PartnerStoreManagementState {
  const PartnerStoreManagementState._();

  const factory PartnerStoreManagementState({
    @Default(false) bool isFormVisible,
    @Default(false) bool isSubmitted,
    @Default(false) bool isEditMode,
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoadingInitialData,
    @Default('') String storeName,
    @Default('') String category,
    @Default('') String businessNumber,
    @Default('') String address,
    @Default('') String latitude,
    @Default('') String longitude,
    @Default('') String storeContact,
    @Default(false) bool depositEnabled,
    @Default('0') String depositAmount,
    @Default(<StoreMenu>[]) List<StoreMenu> menus,
    @Default(<StoreImage>[]) List<StoreImage> images,
    @Default(_defaultOperatingHours)
    Map<String, Map<String, dynamic>> operatingHours,
  }) = _PartnerStoreManagementState;

  bool get canSubmit {
    final parsedDepositAmount = int.tryParse(depositAmount.trim());
    final isDepositValid = depositEnabled
        ? parsedDepositAmount != null && parsedDepositAmount > 0
        : parsedDepositAmount != null && parsedDepositAmount == 0;
    final isMenusValid = menus.every(
      (menu) =>
          menu.name.trim().isNotEmpty && menu.price >= 0 && menu.sortOrder >= 0,
    );
    var coverCount = 0;
    final isImagesValid = images.every((image) {
      if (image.isCover) {
        coverCount += 1;
      }
      return image.imageUrl.trim().isNotEmpty && image.sortOrder >= 0;
    });

    var hasOpenedDay = false;
    for (final dayConfig in operatingHours.values) {
      final isOpened = dayConfig['isOpened'] == true;
      final openTime = dayConfig['openTime'];
      final closeTime = dayConfig['closeTime'];
      if (!isOpened) {
        continue;
      }
      hasOpenedDay = true;
      if (openTime is! String || closeTime is! String) {
        return false;
      }
      if (openTime.isEmpty || closeTime.isEmpty || openTime == closeTime) {
        return false;
      }
    }

    return storeName.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        businessNumber.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        latitude.trim().isNotEmpty &&
        longitude.trim().isNotEmpty &&
        storeContact.trim().isNotEmpty &&
        isDepositValid &&
        isMenusValid &&
        isImagesValid &&
        coverCount <= 1 &&
        hasOpenedDay &&
        !isLoadingInitialData &&
        !isSubmitting;
  }
}
