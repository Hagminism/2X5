import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation_confirm_event.freezed.dart';

@freezed
sealed class SalonReservationConfirmEvent with _$SalonReservationConfirmEvent {
  const factory SalonReservationConfirmEvent.pop() = PopConfirmScreen;
  const factory SalonReservationConfirmEvent.showSnackBar(String message) =
      ShowConfirmSnackBar;
  const factory SalonReservationConfirmEvent.navigateHome() = NavigateToHome;
}
