import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_reservations_event.freezed.dart';

@freezed
sealed class PartnerReservationsEvent with _$PartnerReservationsEvent {
  const factory PartnerReservationsEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMessage;

  const factory PartnerReservationsEvent.openDatePicker(
    DateTime? selectedDate,
  ) = OpenDatePicker;
}
