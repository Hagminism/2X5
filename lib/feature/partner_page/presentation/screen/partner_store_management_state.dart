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
    @Default(_defaultOperatingHours)
    Map<String, Map<String, dynamic>> operatingHours,
  }) = _PartnerStoreManagementState;

  bool get canSubmit {
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
        hasOpenedDay &&
        !isLoadingInitialData &&
        !isSubmitting;
  }
}
