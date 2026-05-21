import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_management_state.freezed.dart';

@freezed
abstract class PartnerSalonManagementState with _$PartnerSalonManagementState {
  const factory PartnerSalonManagementState({
    @Default(false) bool isLoading,
  }) = _PartnerSalonManagementState;
}
