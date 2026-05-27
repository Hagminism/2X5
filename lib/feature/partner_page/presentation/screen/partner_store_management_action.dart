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

  const factory PartnerStoreManagementAction.changeDepositEnabled(bool value) =
      ChangeDepositEnabled;

  const factory PartnerStoreManagementAction.changeDepositAmount(String value) =
      ChangeDepositAmount;

  const factory PartnerStoreManagementAction.changeReservationSlotMinutes(
    int minutes,
  ) = ChangeReservationSlotMinutes;

  const factory PartnerStoreManagementAction.tapOpenMenuManager() =
      TapOpenMenuManager;

  const factory PartnerStoreManagementAction.tapOpenLayoutManager() =
      TapOpenLayoutManager;

  const factory PartnerStoreManagementAction.tapOpenSeatLayoutManager() =
      TapOpenSeatLayoutManager;

  const factory PartnerStoreManagementAction.tapOpenStudyCafeUsageOptionManager() =
      TapOpenStudyCafeUsageOptionManager;

  const factory PartnerStoreManagementAction.tapOpenSalonManager() =
      TapOpenSalonManager;

  const factory PartnerStoreManagementAction.tapOpenImageManager() =
      TapOpenImageManager;

  const factory PartnerStoreManagementAction.addMenu() = AddMenu;

  const factory PartnerStoreManagementAction.removeMenu(int index) = RemoveMenu;

  const factory PartnerStoreManagementAction.changeMenuName({
    required int index,
    required String value,
  }) = ChangeMenuName;

  const factory PartnerStoreManagementAction.changeMenuPrice({
    required int index,
    required String value,
  }) = ChangeMenuPrice;

  const factory PartnerStoreManagementAction.changeMenuDescription({
    required int index,
    required String value,
  }) = ChangeMenuDescription;

  const factory PartnerStoreManagementAction.changeMenuImageUrl({
    required int index,
    required String value,
  }) = ChangeMenuImageUrl;

  const factory PartnerStoreManagementAction.toggleMenuAvailable({
    required int index,
    required bool value,
  }) = ToggleMenuAvailable;

  const factory PartnerStoreManagementAction.addStoreImage() = AddStoreImage;

  const factory PartnerStoreManagementAction.removeStoreImage(int index) =
      RemoveStoreImage;

  const factory PartnerStoreManagementAction.changeStoreImageUrl({
    required int index,
    required String value,
  }) = ChangeStoreImageUrl;

  const factory PartnerStoreManagementAction.changeStoreImageCaption({
    required int index,
    required String value,
  }) = ChangeStoreImageCaption;

  const factory PartnerStoreManagementAction.selectCoverImage(int index) =
      SelectCoverImage;

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

  const factory PartnerStoreManagementAction.changeDescription(String value) =
      ChangeDescription;

  const factory PartnerStoreManagementAction.tapSubmit() = TapSubmit;
}
