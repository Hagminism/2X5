import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'salon_reservation_confirm_event.freezed.dart';

@freezed
sealed class SalonReservationConfirmEvent with _$SalonReservationConfirmEvent {
  const factory SalonReservationConfirmEvent.pop() = PopConfirmScreen;
  const factory SalonReservationConfirmEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowConfirmSnackBar;
  const factory SalonReservationConfirmEvent.navigateHome() = NavigateToHome;
}
