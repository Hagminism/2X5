import 'package:capstone_2026/core/data/data_source/reservation/reservation_data_source.dart';
import 'package:capstone_2026/core/data/dto/reservation/reservation_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationDataSourceImpl implements ReservationDataSource {
  final SupabaseClient _supabaseClient;

  ReservationDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

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
