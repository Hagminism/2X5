import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_event.freezed.dart';

@freezed
sealed class ReservationEvent with _$ReservationEvent {
  const factory ReservationEvent.showSnackBar(String message) =
      ReservationShowSnackBar;

  const factory ReservationEvent.showConfirmDialog({
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
  }) = ReservationShowConfirmDialog;

  const factory ReservationEvent.showSuccessDialog({
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
  }) = ReservationShowSuccessDialog;
}
