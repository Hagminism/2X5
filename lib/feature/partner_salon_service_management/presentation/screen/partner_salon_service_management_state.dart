import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
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
    @Default([]) List<SalonService> services,
  }) = _PartnerSalonServiceManagementState;
}
