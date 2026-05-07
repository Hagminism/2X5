import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_slot_interval.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservation_slot_settings_state.freezed.dart';

@freezed
abstract class PartnerReservationSlotSettingsState
    with _$PartnerReservationSlotSettingsState {
  const PartnerReservationSlotSettingsState._();

  const factory PartnerReservationSlotSettingsState({
    required DateTime selectedDate,
    @Default(ReservationSlotInterval.minutes30)
    ReservationSlotInterval slotInterval,
    @Default([]) List<PartnerReservationSlot> slots,
  }) = _PartnerReservationSlotSettingsState;

  factory PartnerReservationSlotSettingsState.initial() {
    return PartnerReservationSlotSettingsState(
      selectedDate: DateTime.now(),
    );
  }
}
