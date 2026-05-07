import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_slot_interval.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservation_slot_settings_action.freezed.dart';

@freezed
sealed class PartnerReservationSlotSettingsAction
    with _$PartnerReservationSlotSettingsAction {
  const factory PartnerReservationSlotSettingsAction.tapDatePicker() =
      TapDatePicker;

  const factory PartnerReservationSlotSettingsAction.selectDate(
    DateTime date,
  ) = SelectDate;

  const factory PartnerReservationSlotSettingsAction.changeSlotInterval(
    ReservationSlotInterval interval,
  ) = ChangeSlotInterval;

  const factory PartnerReservationSlotSettingsAction.toggleSlotOpen({
    required String time,
    required bool isOpen,
  }) = ToggleSlotOpen;

  const factory PartnerReservationSlotSettingsAction.tapIncreaseMaxTeamCount(
    String time,
  ) = TapIncreaseMaxTeamCount;

  const factory PartnerReservationSlotSettingsAction.tapDecreaseMaxTeamCount(
    String time,
  ) = TapDecreaseMaxTeamCount;
}
