import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_dashboard_event.freezed.dart';

@freezed
sealed class PartnerDashboardEvent with _$PartnerDashboardEvent {
  const factory PartnerDashboardEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;
}
