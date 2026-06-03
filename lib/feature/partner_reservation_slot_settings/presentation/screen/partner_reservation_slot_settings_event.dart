import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_reservation_slot_settings_event.freezed.dart';

@freezed
sealed class PartnerReservationSlotSettingsEvent
    with _$PartnerReservationSlotSettingsEvent {
  const factory PartnerReservationSlotSettingsEvent.openDatePicker(
    DateTime selectedDate,
  ) = OpenDatePicker;

  const factory PartnerReservationSlotSettingsEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowSnackBar;
}
