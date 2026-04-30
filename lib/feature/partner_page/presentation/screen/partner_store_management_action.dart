import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_management_action.freezed.dart';

@freezed
sealed class PartnerStoreManagementAction with _$PartnerStoreManagementAction {
  const factory PartnerStoreManagementAction.tapShowRegistrationForm() =
      TapShowRegistrationForm;

  const factory PartnerStoreManagementAction.changeStoreName(String value) =
      ChangeStoreName;

  const factory PartnerStoreManagementAction.changeCategory(String value) =
      ChangeCategory;

  const factory PartnerStoreManagementAction.changeBusinessNumber(String value) =
      ChangeBusinessNumber;

  const factory PartnerStoreManagementAction.changeAddress(String value) =
      ChangeAddress;

  const factory PartnerStoreManagementAction.changeLatitude(String value) =
      ChangeLatitude;

  const factory PartnerStoreManagementAction.changeLongitude(String value) =
      ChangeLongitude;

  const factory PartnerStoreManagementAction.changeContact(String value) =
      ChangeContact;

  const factory PartnerStoreManagementAction.changeOperatingHours(String value) =
      ChangeOperatingHours;

  const factory PartnerStoreManagementAction.tapSubmit() = TapSubmit;
}
