import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_management_action.freezed.dart';

@freezed
sealed class PartnerSalonManagementAction with _$PartnerSalonManagementAction {
  const factory PartnerSalonManagementAction.tapBack() =
      PartnerSalonManagementTapBack;

  const factory PartnerSalonManagementAction.tapRetry() =
      PartnerSalonManagementTapRetry;

  const factory PartnerSalonManagementAction.selectSlotMinutes(int minutes) =
      PartnerSalonManagementSelectSlotMinutes;

  const factory PartnerSalonManagementAction.openDesignerManagement() =
      PartnerSalonManagementOpenDesignerManagement;

  const factory PartnerSalonManagementAction.openServiceManagement() =
      PartnerSalonManagementOpenServiceManagement;

  const factory PartnerSalonManagementAction.tapAddDesigner() =
      PartnerSalonManagementTapAddDesigner;

  const factory PartnerSalonManagementAction.tapRemoveDesigner(int index) =
      PartnerSalonManagementTapRemoveDesigner;

  const factory PartnerSalonManagementAction.changeDesignerName({
    required int index,
    required String value,
  }) = PartnerSalonManagementChangeDesignerName;

  const factory PartnerSalonManagementAction.changeDesignerIntroduction({
    required int index,
    required String value,
  }) = PartnerSalonManagementChangeDesignerIntroduction;

  const factory PartnerSalonManagementAction.tapPickDesignerImage(int index) =
      PartnerSalonManagementTapPickDesignerImage;

  const factory PartnerSalonManagementAction.removeDesignerImage(int index) =
      PartnerSalonManagementRemoveDesignerImage;

  const factory PartnerSalonManagementAction.toggleDesignerActive({
    required int index,
    required bool value,
  }) = PartnerSalonManagementToggleDesignerActive;

  const factory PartnerSalonManagementAction.tapSaveDesigners() =
      PartnerSalonManagementTapSaveDesigners;

  const factory PartnerSalonManagementAction.selectDesigner(String designerId) =
      PartnerSalonManagementSelectDesigner;

  const factory PartnerSalonManagementAction.tapAddService() =
      PartnerSalonManagementTapAddService;

  const factory PartnerSalonManagementAction.tapEditService(
    SalonService service,
  ) = PartnerSalonManagementTapEditService;

  const factory PartnerSalonManagementAction.tapToggleService(
    SalonService service,
  ) = PartnerSalonManagementTapToggleService;

  const factory PartnerSalonManagementAction.tapEditSchedule(
    SalonDesignerSchedule schedule,
  ) = PartnerSalonManagementTapEditSchedule;
}
