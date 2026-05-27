import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_action.freezed.dart';

@freezed
sealed class ReservationAction with _$ReservationAction {
  const factory ReservationAction.tapBack() = ReservationTapBack;

  const factory ReservationAction.selectDay(DateTime day) =
      ReservationSelectDay;

  const factory ReservationAction.selectTime(String time) =
      ReservationSelectTime;

  const factory ReservationAction.tapIncreaseGuestCount() =
      ReservationTapIncreaseGuestCount;

  const factory ReservationAction.tapDecreaseGuestCount() =
      ReservationTapDecreaseGuestCount;

  const factory ReservationAction.tapSubmit() = ReservationTapSubmit;

  const factory ReservationAction.confirmSubmit() = ReservationConfirmSubmit;

  const factory ReservationAction.tapRetry() = ReservationTapRetry;
}
