import 'package:capstone_2026/core/domain/model/salon/salon_settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_management_state.freezed.dart';

@freezed
abstract class PartnerSalonManagementState with _$PartnerSalonManagementState {
  const factory PartnerSalonManagementState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? saveMessage,
    @Default(SalonSettings(storeId: '')) SalonSettings settings,
  }) = _PartnerSalonManagementState;
}
