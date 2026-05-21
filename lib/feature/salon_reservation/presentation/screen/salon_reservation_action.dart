import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation_action.freezed.dart';

@freezed
sealed class SalonReservationAction with _$SalonReservationAction {
  const factory SalonReservationAction.tapBack() = SalonReservationTapBack;

  const factory SalonReservationAction.tapRetry() = SalonReservationTapRetry;

  const factory SalonReservationAction.selectDesigner(String designerId) =
      SalonReservationSelectDesigner;

  const factory SalonReservationAction.selectService(String serviceId) =
      SalonReservationSelectService;

  const factory SalonReservationAction.selectDate(DateTime date) =
      SalonReservationSelectDate;

  const factory SalonReservationAction.selectSlot(DateTime startAt) =
      SalonReservationSelectSlot;

  const factory SalonReservationAction.tapSubmit() = SalonReservationTapSubmit;
}
