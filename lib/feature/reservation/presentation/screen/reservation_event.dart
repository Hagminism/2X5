import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'reservation_event.freezed.dart';

@freezed
sealed class ReservationEvent with _$ReservationEvent {
  const factory ReservationEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ReservationShowSnackBar;

  const factory ReservationEvent.showConfirmDialog({
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
    String? customerRequest,
  }) = ReservationShowConfirmDialog;

  const factory ReservationEvent.showSuccessDialog({
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
    String? customerRequest,
  }) = ReservationShowSuccessDialog;
}
