import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation_confirm_action.freezed.dart';

@freezed
sealed class SalonReservationConfirmAction
    with _$SalonReservationConfirmAction {
  const factory SalonReservationConfirmAction.tapBack() = TapConfirmBack;
  const factory SalonReservationConfirmAction.tapConfirm() =
      TapConfirmReservation;
}
