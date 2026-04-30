import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_management_state.freezed.dart';

@freezed
abstract class PartnerStoreManagementState with _$PartnerStoreManagementState {
  const PartnerStoreManagementState._();

  const factory PartnerStoreManagementState({
    @Default(false) bool isFormVisible,
    @Default(false) bool isSubmitted,
    @Default(false) bool isSubmitting,
    @Default('') String storeName,
    @Default('') String category,
    @Default('') String businessNumber,
    @Default('') String address,
    @Default('') String latitude,
    @Default('') String longitude,
    @Default('') String contact,
    @Default('') String operatingHours,
  }) = _PartnerStoreManagementState;

  bool get canSubmit {
    return storeName.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        businessNumber.trim().isNotEmpty &&
        address.trim().isNotEmpty &&
        latitude.trim().isNotEmpty &&
        longitude.trim().isNotEmpty &&
        contact.trim().isNotEmpty &&
        operatingHours.trim().isNotEmpty &&
        !isSubmitting;
  }
}
