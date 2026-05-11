import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_management_event.freezed.dart';

@freezed
sealed class PartnerStoreManagementEvent with _$PartnerStoreManagementEvent {
  const factory PartnerStoreManagementEvent.showMessage(String message) =
      ShowMessage;
  const factory PartnerStoreManagementEvent.openAddressSearch() =
      OpenAddressSearch;
  const factory PartnerStoreManagementEvent.openMenuManager() = OpenMenuManager;
  const factory PartnerStoreManagementEvent.openImageManager() =
      OpenImageManager;
}
