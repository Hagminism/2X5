import 'package:capstone_2026/core/data/dto/reservation/reservation_dto.dart';
import 'package:capstone_2026/core/data/dto/reservation/store_reservation_slot_default_dto.dart';
import 'package:capstone_2026/core/data/dto/reservation/store_schedule_exception_dto.dart';

abstract interface class ReservationDataSource {
  Future<List<ReservationDto>> findReservationsByStoreId(String storeId);

  Future<List<ReservationDto>> findReservationsByStoreIdAndDate({
    required String storeId,
    required String bookingDate,
  });

  Future<ReservationDto> createReservationViaCallable({
    required String storeId,
    required String bookingDate,
    required String bookingTime,
    required int guestCount,
    String? customerRequest,
  });

  Future<List<StoreReservationSlotDefaultDto>> findSlotDefaultsByStoreId(
    String storeId,
  );

  Future<void> saveSlotDefaults({
    required String storeId,
    required List<StoreReservationSlotDefaultDto> defaults,
  });

  Future<StoreScheduleExceptionDto?> findScheduleException({
    required String storeId,
    required String exceptionDate,
  });

  Future<StoreScheduleExceptionDto> upsertScheduleException(
    StoreScheduleExceptionDto exception,
  );

  Future<void> deleteScheduleException({
    required String storeId,
    required String exceptionDate,
  });

  Future<ReservationDto> updateReservationStatus({
    required String reservationId,
    required String status,
  });
}
