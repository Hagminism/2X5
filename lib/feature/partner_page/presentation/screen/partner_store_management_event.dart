import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_store_management_event.freezed.dart';

@freezed
sealed class PartnerStoreManagementEvent with _$PartnerStoreManagementEvent {
  const factory PartnerStoreManagementEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMessage;
  const factory PartnerStoreManagementEvent.openAddressSearch() =
      OpenAddressSearch;
  const factory PartnerStoreManagementEvent.openMenuManager() = OpenMenuManager;
  const factory PartnerStoreManagementEvent.openLayoutManager() =
      OpenLayoutManager;
  const factory PartnerStoreManagementEvent.openSeatLayoutManager() =
      OpenSeatLayoutManager;
  const factory PartnerStoreManagementEvent.openStudyCafeUsageOptionManager() =
      OpenStudyCafeUsageOptionManager;
  const factory PartnerStoreManagementEvent.openSalonManager() =
      OpenSalonManager;
  const factory PartnerStoreManagementEvent.openImageManager() =
      OpenImageManager;
}
