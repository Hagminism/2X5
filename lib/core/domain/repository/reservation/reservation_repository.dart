import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';

abstract interface class ReservationRepository {
  Future<List<Reservation>> fetchReservations();

  Future<Reservation> updateReservationStatus({
    required String reservationId,
    required ReservationStatus status,
  });
}
