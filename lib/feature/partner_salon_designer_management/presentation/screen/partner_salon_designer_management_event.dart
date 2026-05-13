import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_designer_management_event.freezed.dart';

@freezed
sealed class PartnerSalonDesignerManagementEvent
    with _$PartnerSalonDesignerManagementEvent {
  const factory PartnerSalonDesignerManagementEvent.showMessage(
    String message,
  ) = PartnerSalonDesignerManagementShowMessage;

  const factory PartnerSalonDesignerManagementEvent.openGallery(int index) =
      PartnerSalonDesignerManagementOpenGallery;

  const factory PartnerSalonDesignerManagementEvent.pop() =
      PartnerSalonDesignerManagementPop;

  const factory PartnerSalonDesignerManagementEvent.popWithMessage(
    String message,
  ) = PartnerSalonDesignerManagementPopWithMessage;
}
