import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:capstone_2026/feature/address_search/domain/model/address_search_result.dart';

part 'partner_store_management_action.freezed.dart';

@freezed
sealed class PartnerStoreManagementAction with _$PartnerStoreManagementAction {
  const factory PartnerStoreManagementAction.tapShowRegistrationForm() =
      TapShowRegistrationForm;

  const factory PartnerStoreManagementAction.changeStoreName(String value) =
      ChangeStoreName;

  const factory PartnerStoreManagementAction.changeCategory(String value) =
      ChangeCategory;

  const factory PartnerStoreManagementAction.changeBusinessNumber(
    String value,
  ) = ChangeBusinessNumber;

  const factory PartnerStoreManagementAction.tapAddressSearch() =
      TapAddressSearch;

  const factory PartnerStoreManagementAction.selectAddressSearchResult(
    AddressSearchResult result,
  ) = SelectAddressSearchResult;

  const factory PartnerStoreManagementAction.changeStoreContact(String value) =
      ChangeStoreContact;

  const factory PartnerStoreManagementAction.toggleDayOpened({
    required String day,
    required bool isOpened,
  }) = ToggleDayOpened;

  const factory PartnerStoreManagementAction.changeDayOpenTime({
    required String day,
    required String value,
  }) = ChangeDayOpenTime;

  const factory PartnerStoreManagementAction.changeDayCloseTime({
    required String day,
    required String value,
  }) = ChangeDayCloseTime;

  const factory PartnerStoreManagementAction.tapSubmit() = TapSubmit;
}
