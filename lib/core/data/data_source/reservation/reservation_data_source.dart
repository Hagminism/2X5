import 'package:capstone_2026/core/data/dto/reservation/reservation_dto.dart';

abstract interface class ReservationDataSource {
  Future<List<ReservationDto>> findReservationsByStoreId(String storeId);

  Future<ReservationDto> updateReservationStatus({
    required String reservationId,
    required String status,
  });
}
