import 'package:capstone_2026/core/data/data_source/salon/salon_data_source.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_settings.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalonDataSourceImpl implements SalonDataSource {
  final SupabaseClient _supabaseClient;
  final FirebaseFunctions _firebaseFunctions;

  const SalonDataSourceImpl({
    required SupabaseClient supabaseClient,
    required FirebaseFunctions firebaseFunctions,
  }) : _supabaseClient = supabaseClient,
       _firebaseFunctions = firebaseFunctions;

  @override
  Future<SalonSettings?> findSettingsByStoreId(String storeId) async {
    final json = await _supabaseClient
        .from('salon_settings')
        .select()
        .eq('store_id', storeId)
        .maybeSingle();
    if (json == null) {
      return null;
    }
    return SalonSettings.fromJson(json);
  }

  @override
  Future<List<SalonDesigner>> findDesignersByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('salon_designers')
        .select()
        .eq('store_id', storeId)
        .order('sort_order')
        .order('created_at');
    return jsonList.map((json) => SalonDesigner.fromJson(json)).toList();
  }

  @override
  Future<List<SalonService>> findServicesByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('salon_services')
        .select()
        .eq('store_id', storeId)
        .order('sort_order')
        .order('created_at');
    return jsonList.map((json) => SalonService.fromJson(json)).toList();
  }

  @override
  Future<List<SalonDesignerSchedule>> findSchedulesByDesignerId(
    String designerId,
  ) async {
    final jsonList = await _supabaseClient
        .from('salon_designer_schedules')
        .select()
        .eq('designer_id', designerId)
        .order('day_of_week');
    return jsonList
        .map((json) => SalonDesignerSchedule.fromJson(json))
        .toList();
  }

  @override
  Future<List<SalonReservation>> findReservationsByDesignerAndDate({
    required String storeId,
    required String designerId,
    required DateTime date,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final jsonList = await _supabaseClient
        .from('salon_reservations')
        .select()
        .eq('store_id', storeId)
        .eq('designer_id', designerId)
        .eq('status', 'confirmed')
        .gte('start_at', start.toIso8601String())
        .lt('start_at', end.toIso8601String())
        .order('start_at');
    return jsonList.map((json) => SalonReservation.fromJson(json)).toList();
  }

  @override
  Future<SalonSettings> upsertSettings(SalonSettings settings) async {
    final callable = _firebaseFunctions.httpsCallable('saveSalonSettings');
    final result = await callable.call<Map<String, dynamic>>({
      'storeId': settings.storeId,
      'slotMinutes': settings.slotMinutes,
    });
    return SalonSettings.fromJson(Map<String, Object?>.from(result.data));
  }

  @override
  Future<List<SalonDesigner>> upsertDesigners(
    List<SalonDesigner> designers,
  ) async {
    if (designers.isEmpty) {
      return const [];
    }
    final callable = _firebaseFunctions.httpsCallable('saveSalonDesigners');
    final result = await callable.call<List<dynamic>>({
      'storeId': designers.first.storeId,
      'designers': designers
          .map(
            (designer) => {
              'id': designer.id,
              'name': designer.name,
              'introduction': designer.introduction,
              'imageUrl': designer.imageUrl,
              'isActive': designer.isActive,
              'sortOrder': designer.sortOrder,
            },
          )
          .toList(),
    });
    final jsonList = _listFromCallableData(result.data);
    return jsonList.map((json) => SalonDesigner.fromJson(json)).toList();
  }

  @override
  Future<List<SalonService>> upsertServices(List<SalonService> services) async {
    if (services.isEmpty) {
      return const [];
    }
    final callable = _firebaseFunctions.httpsCallable('saveSalonServices');
    final result = await callable.call<List<dynamic>>({
      'storeId': services.first.storeId,
      'services': services
          .map(
            (service) => {
              'id': service.id,
              'name': service.name,
              'description': service.description,
              'durationMinutes': service.durationMinutes,
              'price': service.price,
              'isActive': service.isActive,
              'sortOrder': service.sortOrder,
            },
          )
          .toList(),
    });
    final jsonList = _listFromCallableData(result.data);
    return jsonList.map((json) => SalonService.fromJson(json)).toList();
  }

  @override
  Future<List<SalonDesignerSchedule>> upsertSchedules(
    List<SalonDesignerSchedule> schedules,
  ) async {
    if (schedules.isEmpty) {
      return const [];
    }
    final callable = _firebaseFunctions.httpsCallable(
      'saveSalonDesignerSchedules',
    );
    final result = await callable.call<List<dynamic>>({
      'storeId': await _storeIdForDesigner(schedules.first.designerId),
      'schedules': schedules
          .map(
            (schedule) => {
              'id': schedule.id,
              'designerId': schedule.designerId,
              'dayOfWeek': schedule.dayOfWeek,
              'isWorking': schedule.isWorking,
              'startTime': schedule.startTime,
              'endTime': schedule.endTime,
            },
          )
          .toList(),
    });
    final jsonList = _listFromCallableData(result.data);
    return jsonList
        .map((json) => SalonDesignerSchedule.fromJson(json))
        .toList();
  }

  @override
  Future<SalonReservation> createReservation({
    required String storeId,
    required String userId,
    required String designerId,
    required String serviceId,
    required DateTime startAt,
  }) async {
    final callable = _firebaseFunctions.httpsCallable('createSalonReservation');
    final result = await callable.call<Map<String, dynamic>>({
      'storeId': storeId,
      'designerId': designerId,
      'serviceId': serviceId,
      'startAt': startAt.toIso8601String(),
    });
    return SalonReservation.fromJson(Map<String, Object?>.from(result.data));
  }

  Future<String> _storeIdForDesigner(String designerId) async {
    final json = await _supabaseClient
        .from('salon_designers')
        .select('store_id')
        .eq('id', designerId)
        .single();
    return json['store_id'].toString();
  }

  List<Map<String, Object?>> _listFromCallableData(Object? data) {
    if (data is! List) {
      throw StateError('Cloud Functions 응답 형식이 올바르지 않습니다.');
    }
    return data
        .whereType<Map>()
        .map((json) => Map<String, Object?>.from(json))
        .toList();
  }
}
