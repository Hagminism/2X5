import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_dashboard_action.freezed.dart';

@freezed
sealed class PartnerDashboardAction with _$PartnerDashboardAction {
  const factory PartnerDashboardAction.tapEditStore() = TapEditStore;

  const factory PartnerDashboardAction.tapManageReservations() =
      TapManageReservations;
}
