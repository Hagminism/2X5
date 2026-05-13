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
}
