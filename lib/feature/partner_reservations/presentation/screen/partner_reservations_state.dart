import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservations_state.freezed.dart';

@freezed
abstract class PartnerReservationsState with _$PartnerReservationsState {
  const PartnerReservationsState._();

  const factory PartnerReservationsState({
    @Default(false) bool isLoading,
    @Default(false) bool isUpdating,
    String? updatingReservationId,
    ReservationStatus? selectedStatus,
    DateTime? selectedDate,
    @Default([]) List<Reservation> reservations,
  }) = _PartnerReservationsState;

  List<Reservation> get filteredReservations {
    return reservations.where((item) {
      final status = selectedStatus;
      if (status != null && item.status != status) {
        return false;
      }

      final date = selectedDate;
      if (date != null && !_isSameDate(item.bookingDate, date)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _isSameDate(DateTime source, DateTime target) {
    return source.year == target.year &&
        source.month == target.month &&
        source.day == target.day;
  }
}
