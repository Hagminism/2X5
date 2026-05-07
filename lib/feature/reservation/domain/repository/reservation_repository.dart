import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'reservations'; // 테이블명 상수화

  Future<void> createReservation({
    required String date,
    required String? time,
    required int guestCount,
  }) async {
    try {
      await _supabase.from(_tableName).insert({
        'booking_date': date,
        'booking_time': time,
        'guest_count': guestCount,
      });
    } catch (e) {
      throw Exception('예약 저장 실패: $e');
    }
  }
}