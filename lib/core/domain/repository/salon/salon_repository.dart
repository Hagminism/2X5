import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_settings.dart';

abstract interface class SalonRepository {
  Future<SalonSettings> getSettingsByStoreId(String storeId);

  Future<SalonSettings> getMyStoreSettings();

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

  Future<SalonSettings> saveMyStoreSettings(SalonSettings settings);

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
    required String serviceId,
    required DateTime startAt,
  });
}
