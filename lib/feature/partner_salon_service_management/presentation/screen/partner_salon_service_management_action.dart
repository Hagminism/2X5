import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_service_management_action.freezed.dart';

@freezed
sealed class PartnerSalonServiceManagementAction
    with _$PartnerSalonServiceManagementAction {
  const factory PartnerSalonServiceManagementAction.tapBack() =
      PartnerSalonServiceManagementTapBack;

  const factory PartnerSalonServiceManagementAction.tapRetry() =
      PartnerSalonServiceManagementTapRetry;

  const factory PartnerSalonServiceManagementAction.tapAddService() =
      PartnerSalonServiceManagementTapAddService;

  const factory PartnerSalonServiceManagementAction.tapEditService(
    SalonService service,
  ) = PartnerSalonServiceManagementTapEditService;

  const factory PartnerSalonServiceManagementAction.tapToggleService(
    SalonService service,
  ) = PartnerSalonServiceManagementTapToggleService;
}
