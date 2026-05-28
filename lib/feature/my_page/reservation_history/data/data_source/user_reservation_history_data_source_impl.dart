import 'package:capstone_2026/feature/my_page/reservation_history/data/data_source/user_reservation_history_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserReservationHistoryDataSourceImpl
    implements UserReservationHistoryDataSource {
  UserReservationHistoryDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const String _storeSelect = 'stores ( name, category )';

  @override
  Future<List<Map<String, dynamic>>> fetchRestaurantReservationsByUserId(
    String userId,
  ) async {
    final jsonList = await _supabaseClient
        .from('reservations')
        .select('''
          id,
          store_id,
          booking_date,
          booking_time,
          guest_count,
          status,
          total_price,
          customer_request,
          created_at,
          $_storeSelect
        ''')
        .eq('user_id', userId);

    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStudyCafeReservationsByUserId(
    String userId,
  ) async {
    final jsonList = await _supabaseClient
        .from('studycafe_reservations')
        .select('''
          id,
          store_id,
          seat_id,
          duration_minutes,
          start_at,
          end_at,
          status,
          created_at,
          $_storeSelect
        ''')
        .eq('user_id', userId);

    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSalonReservationsByUserId(
    String userId,
  ) async {
    final jsonList = await _supabaseClient
        .from('salon_reservations')
        .select('''
          id,
          store_id,
          designer_id,
          service_ids,
          start_at,
          end_at,
          status,
          created_at,
          $_storeSelect
        ''')
        .eq('user_id', userId);

    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReviewsByUserId(
    String userId,
  ) async {
    final jsonList = await _supabaseClient
        .from('reviews')
        .select('id, store_id')
        .eq('user_id', userId)
        .eq('is_visible', true);

    return jsonList.cast<Map<String, dynamic>>();
  }
}
