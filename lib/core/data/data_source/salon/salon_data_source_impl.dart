import 'package:capstone_2026/core/data/data_source/salon/salon_data_source.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
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
  Future<List<SalonDesigner>> findDesignersByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('salon_designers')
        .select()
        .eq('store_id', storeId)
        .order('created_at');
    return jsonList.map((json) => SalonDesigner.fromJson(json)).toList();
  }

  @override
  Future<List<SalonService>> findServicesByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('salon_services')
        .select()
        .eq('store_id', storeId)
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
  Future<List<SalonDesigner>> upsertDesigners(
    List<SalonDesigner> designers,
  ) async {
    if (designers.isEmpty) {
      return const [];
    }
    final payload = designers.map((designer) {
      final json = designer.toJson()
        ..remove('created_at')
        ..['updated_at'] = DateTime.now().toIso8601String();
      if ((json['id'] as String?)?.isEmpty ?? true) {
        json.remove('id');
      }
      return json;
    }).toList();
    final jsonList = await _supabaseClient
        .from('salon_designers')
        .upsert(payload)
        .select();
    return jsonList.map((json) => SalonDesigner.fromJson(json)).toList();
  }

  @override
  Future<List<SalonService>> upsertServices(List<SalonService> services) async {
    if (services.isEmpty) {
      return const [];
    }
    final payload = services.map((service) {
      final json = service.toJson()
        ..remove('created_at')
        ..['updated_at'] = DateTime.now().toIso8601String();
      if ((json['id'] as String?)?.isEmpty ?? true) {
        json.remove('id');
      }
      return json;
    }).toList();
    final jsonList = await _supabaseClient
        .from('salon_services')
        .upsert(payload)
        .select();
    return jsonList.map((json) => SalonService.fromJson(json)).toList();
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
}
