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
    @Default(30) int reservationSlotMinutes,
    @Default(<StoreMenu>[]) List<StoreMenu> menus,
    @Default(<StoreImage>[]) List<StoreImage> images,
    @Default(_defaultOperatingHours)
    Map<String, Map<String, dynamic>> operatingHours,
    @Default('') String description,
    @Default(false) bool isStampEnabled,
    @Default(10) int stampGoalCount,
    @Default('') String stampRewardTitle,
    @Default('') String stampRewardDescription,
  }) = _PartnerStoreManagementState;

  /// 최초 업장 등록 완료 후에만 카테고리별 관리·사진 진입 허용.
  bool get canAccessStoreSubManagers => isEditMode;

  bool get canSubmit {
    final parsedDepositAmount = int.tryParse(depositAmount.trim());
    final isReservationSlotValid =
        reservationSlotMinutes == 30 || reservationSlotMinutes == 60;
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

    final isStampValid =
        !isStampEnabled ||
        (stampGoalCount > 0 &&
            stampRewardTitle.trim().isNotEmpty &&
            stampRewardDescription.trim().isNotEmpty);

    return storeName.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        businessNumber.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        latitude.trim().isNotEmpty &&
        longitude.trim().isNotEmpty &&
        storeContact.trim().isNotEmpty &&
        isReservationSlotValid &&
        isDepositValid &&
        isMenusValid &&
        isImagesValid &&
        coverCount <= 1 &&
        hasOpenedDay &&
        isStampValid &&
        !isLoadingInitialData &&
        !isSubmitting;
  }
}
