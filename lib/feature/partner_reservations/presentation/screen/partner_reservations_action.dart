import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservations_action.freezed.dart';

@freezed
sealed class PartnerReservationsAction with _$PartnerReservationsAction {
  const factory PartnerReservationsAction.tapRetry() = TapRetry;

  const factory PartnerReservationsAction.tapDateFilter() = TapDateFilter;

  const factory PartnerReservationsAction.selectStatus(
    ReservationStatus? status,
  ) = SelectStatus;

  const factory PartnerReservationsAction.selectDate(
    DateTime? date,
  ) = SelectDate;

  const factory PartnerReservationsAction.tapChangeStatus({
    required String reservationId,
    required ReservationStatus status,
  }) = TapChangeStatus;
}
