import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';

abstract interface class SalonDataSource {
  Future<List<SalonDesigner>> findDesignersByStoreId(String storeId);

  Future<List<SalonService>> findServicesByStoreId(String storeId);

  Future<List<SalonDesignerSchedule>> findSchedulesByDesignerId(
    String designerId,
  );

  Future<List<SalonReservation>> findReservationsByDesignerAndDate({
    required String storeId,
    required String designerId,
    required DateTime date,
  });

  Future<List<SalonDesigner>> upsertDesigners(List<SalonDesigner> designers);

  Future<List<SalonService>> upsertServices(List<SalonService> services);

  Future<List<SalonDesignerSchedule>> upsertSchedules(
    List<SalonDesignerSchedule> schedules,
  );

  Future<SalonReservation> createReservation({
    required String storeId,
    required String userId,
    required String designerId,
    required List<String> serviceIds,
    required DateTime startAt,
    String? customerRequest,
  });
}
