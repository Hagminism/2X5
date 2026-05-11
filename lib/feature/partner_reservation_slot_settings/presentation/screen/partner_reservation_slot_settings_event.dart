import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservation_slot_settings_event.freezed.dart';

@freezed
sealed class PartnerReservationSlotSettingsEvent
    with _$PartnerReservationSlotSettingsEvent {
  const factory PartnerReservationSlotSettingsEvent.openDatePicker(
    DateTime selectedDate,
  ) = OpenDatePicker;
}
