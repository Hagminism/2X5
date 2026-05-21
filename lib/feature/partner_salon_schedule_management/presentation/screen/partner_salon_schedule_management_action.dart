import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_schedule_management_action.freezed.dart';

@freezed
sealed class PartnerSalonScheduleManagementAction
    with _$PartnerSalonScheduleManagementAction {
  const factory PartnerSalonScheduleManagementAction.tapBack() =
      PartnerSalonScheduleManagementTapBack;

  const factory PartnerSalonScheduleManagementAction.tapRetry() =
      PartnerSalonScheduleManagementTapRetry;

  const factory PartnerSalonScheduleManagementAction.selectDesigner(
    String designerId,
  ) = PartnerSalonScheduleManagementSelectDesigner;

  const factory PartnerSalonScheduleManagementAction.tapEditSchedule(
    SalonDesignerSchedule schedule,
  ) = PartnerSalonScheduleManagementTapEditSchedule;
}
