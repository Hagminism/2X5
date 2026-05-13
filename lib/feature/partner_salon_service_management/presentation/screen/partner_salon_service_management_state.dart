import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_service_management_state.freezed.dart';

@freezed
abstract class PartnerSalonServiceManagementState
    with _$PartnerSalonServiceManagementState {
  const factory PartnerSalonServiceManagementState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? saveMessage,
    @Default(SalonSettings(storeId: '')) SalonSettings settings,
    @Default([]) List<SalonDesigner> designers,
    @Default([]) List<SalonService> services,
    @Default([]) List<SalonDesignerSchedule> schedules,
    String? selectedDesignerId,
  }) = _PartnerSalonServiceManagementState;
}
