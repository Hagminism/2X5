import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_schedule_management_state.freezed.dart';

@freezed
abstract class PartnerSalonScheduleManagementState
    with _$PartnerSalonScheduleManagementState {
  const factory PartnerSalonScheduleManagementState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? saveMessage,
    @Default([]) List<SalonDesigner> designers,
    @Default([]) List<SalonDesignerSchedule> schedules,
    String? selectedDesignerId,
  }) = _PartnerSalonScheduleManagementState;
}
