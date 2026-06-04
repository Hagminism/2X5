import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_reservation_slot_default.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_schedule_exception.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';

abstract interface class ReservationRepository {
  Future<List<Reservation>> fetchReservations();

  Future<List<Reservation>> getReservationsByStoreAndDate({
    required String storeId,
    required DateTime date,
  });

  Future<Reservation> createReservation({
    required String storeId,
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
    String? customerRequest,
  });

  Future<List<StoreReservationSlotDefault>> getSlotDefaultsByStoreId(
    String storeId,
  );

  Future<void> saveSlotDefaults({
    required String storeId,
    required List<StoreReservationSlotDefault> defaults,
  });

  Future<StoreScheduleException?> getScheduleException({
    required String storeId,
    required DateTime date,
  });

  Future<StoreScheduleException> upsertScheduleException(
    StoreScheduleException exception,
  );

  Future<void> deleteScheduleException({
    required String storeId,
    required DateTime date,
  });

  Future<List<RestaurantTimeSlot>> getAvailabilityForDate({
    required Store store,
    required DateTime date,
  });

  Future<Reservation> updateReservationStatus({
    required String reservationId,
    required ReservationStatus status,
  });
}
