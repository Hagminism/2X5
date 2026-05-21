import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';

abstract interface class SalonRepository {
  Future<List<SalonDesigner>> getDesignersByStoreId(String storeId);

  Future<List<SalonDesigner>> getMyStoreDesigners();

  Future<List<SalonService>> getServicesByStoreId(String storeId);

  Future<List<SalonService>> getMyStoreServices();

  Future<List<SalonDesignerSchedule>> getSchedulesByDesignerId(
    String designerId,
  );

  Future<List<SalonReservation>> getReservationsByDesignerAndDate({
    required String storeId,
    required String designerId,
    required DateTime date,
  });

  Future<List<SalonDesigner>> saveMyStoreDesigners(
    List<SalonDesigner> designers,
  );

  Future<List<SalonService>> saveMyStoreServices(List<SalonService> services);

  Future<List<SalonDesignerSchedule>> saveMyStoreSchedules(
    List<SalonDesignerSchedule> schedules,
  );

  Future<SalonReservation> createReservation({
    required String storeId,
    required String designerId,
    required List<String> serviceIds,
    required DateTime startAt,
  });
}
