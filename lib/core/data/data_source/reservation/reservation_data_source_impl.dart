import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source.dart';
import 'package:capstone_2026/core/data/dto/reservation/reservation_dto.dart';
import 'package:capstone_2026/core/data/dto/reservation/store_reservation_slot_default_dto.dart';
import 'package:capstone_2026/core/data/dto/reservation/store_schedule_exception_dto.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationDataSourceImpl implements ReservationDataSource {
  final SupabaseClient _supabaseClient;
  final FirebaseFunctions _firebaseFunctions;

  ReservationDataSourceImpl({
    required SupabaseClient supabaseClient,
    required FirebaseFunctions firebaseFunctions,
  }) : _supabaseClient = supabaseClient,
       _firebaseFunctions = firebaseFunctions;

  @override
  Future<List<ReservationDto>> findReservationsByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('reservations')
        .select()
        .eq('store_id', storeId)
        .order('booking_date', ascending: true)
        .order('booking_time', ascending: true);

    return jsonList.map((json) => ReservationDto.fromJson(json)).toList();
  }

  @override
  Future<List<ReservationDto>> findReservationsByStoreIdAndDate({
    required String storeId,
    required String bookingDate,
  }) async {
    final jsonList = await _supabaseClient
        .from('reservations')
        .select()
        .eq('store_id', storeId)
        .eq('booking_date', bookingDate)
        .eq('status', 'confirmed')
        .order('booking_time', ascending: true);

    return jsonList.map((json) => ReservationDto.fromJson(json)).toList();
  }

  @override
  Future<ReservationDto> createReservationViaCallable({
    required String storeId,
    required String bookingDate,
    required String bookingTime,
    required int guestCount,
  }) async {
    final callable =
        _firebaseFunctions.httpsCallable('createRestaurantReservation');
    final result = await callable.call<Map<String, dynamic>>({
      'storeId': storeId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'guestCount': guestCount,
    });
    return ReservationDto.fromJson(Map<String, Object?>.from(result.data));
  }

  @override
  Future<List<StoreReservationSlotDefaultDto>> findSlotDefaultsByStoreId(
    String storeId,
  ) async {
    final jsonList = await _supabaseClient
        .from('store_reservation_slot_defaults')
        .select()
        .eq('store_id', storeId)
        .order('slot_time', ascending: true);

    return jsonList
        .map((json) => StoreReservationSlotDefaultDto.fromJson(json))
        .toList();
  }

  @override
  Future<void> saveSlotDefaults({
    required String storeId,
    required List<StoreReservationSlotDefaultDto> defaults,
  }) async {
    await _supabaseClient
        .from('store_reservation_slot_defaults')
        .delete()
        .eq('store_id', storeId);

    if (defaults.isEmpty) {
      return;
    }

    final rows = defaults
        .map(
          (dto) => {
            'store_id': storeId,
            'slot_time': dto.slotTime,
            'max_guest_count': dto.maxGuestCount,
            'is_open': dto.isOpen,
            'updated_at': DateTime.now().toIso8601String(),
          },
        )
        .toList();

    await _supabaseClient.from('store_reservation_slot_defaults').insert(rows);
  }

  @override
  Future<StoreScheduleExceptionDto?> findScheduleException({
    required String storeId,
    required String exceptionDate,
  }) async {
    final json = await _supabaseClient
        .from('store_schedule_exceptions')
        .select()
        .eq('store_id', storeId)
        .eq('exception_date', exceptionDate)
        .maybeSingle();

    if (json == null) {
      return null;
    }

    return StoreScheduleExceptionDto.fromJson(json);
  }

  @override
  Future<StoreScheduleExceptionDto> upsertScheduleException(
    StoreScheduleExceptionDto exception,
  ) async {
    final json = await _supabaseClient
        .from('store_schedule_exceptions')
        .upsert(
          exception.toJson(),
          onConflict: 'store_id,exception_date',
        )
        .select()
        .single();

    return StoreScheduleExceptionDto.fromJson(json);
  }

  @override
  Future<void> deleteScheduleException({
    required String storeId,
    required String exceptionDate,
  }) async {
    await _supabaseClient
        .from('store_schedule_exceptions')
        .delete()
        .eq('store_id', storeId)
        .eq('exception_date', exceptionDate);
  }

  @override
  Future<ReservationDto> updateReservationStatus({
    required String reservationId,
    required String status,
  }) async {
    final json = await _supabaseClient
        .from('reservations')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reservationId)
        .select()
        .single();

    return ReservationDto.fromJson(json);
  }
}
