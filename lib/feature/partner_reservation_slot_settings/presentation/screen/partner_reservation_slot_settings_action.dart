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

  const factory PartnerReservationSlotSettingsAction.toggleSlotOpen({
    required String time,
    required bool isOpen,
  }) = ToggleSlotOpen;

  const factory PartnerReservationSlotSettingsAction.tapIncreaseMaxGuestCount(
    String time,
  ) = TapIncreaseMaxGuestCount;

  const factory PartnerReservationSlotSettingsAction.tapDecreaseMaxGuestCount(
    String time,
  ) = TapDecreaseMaxGuestCount;

  const factory PartnerReservationSlotSettingsAction.toggleExceptionClosed(
    bool isClosed,
  ) = ToggleExceptionClosed;

  const factory PartnerReservationSlotSettingsAction.changeExceptionOpenTime(
    String? openTime,
  ) = ChangeExceptionOpenTime;

  const factory PartnerReservationSlotSettingsAction.changeExceptionCloseTime(
    String? closeTime,
  ) = ChangeExceptionCloseTime;

  const factory PartnerReservationSlotSettingsAction.tapSave() = TapSave;
}
