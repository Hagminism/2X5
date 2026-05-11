import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';

abstract interface class SalonRepository {
  Future<List<SalonDesigner>> getDesignersByStoreId(String storeId);

  Future<List<SalonService>> getServicesByStoreId(String storeId);

  Future<List<SalonDesignerSchedule>> getSchedulesByDesignerId(
    String designerId,
  );

  Future<List<SalonDesigner>> saveMyStoreDesigners(
    List<SalonDesigner> designers,
  );

  Future<List<SalonService>> saveMyStoreServices(List<SalonService> services);

  Future<SalonReservation> createReservation({
    required String storeId,
    required String designerId,
    required String serviceId,
    required DateTime startAt,
  });
}
