import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_salon_designer_management_event.freezed.dart';

@freezed
sealed class PartnerSalonDesignerManagementEvent
    with _$PartnerSalonDesignerManagementEvent {
  const factory PartnerSalonDesignerManagementEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = PartnerSalonDesignerManagementShowMessage;

  const factory PartnerSalonDesignerManagementEvent.openGallery(int index) =
      PartnerSalonDesignerManagementOpenGallery;

  const factory PartnerSalonDesignerManagementEvent.pop() =
      PartnerSalonDesignerManagementPop;

  const factory PartnerSalonDesignerManagementEvent.popWithMessage(
    String message, {
    @Default(AppSnackBarVariant.success) AppSnackBarVariant variant,
  }) = PartnerSalonDesignerManagementPopWithMessage;
}
