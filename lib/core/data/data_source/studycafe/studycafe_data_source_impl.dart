import 'package:capstone_2026/core/data/data_source/studycafe/studycafe_data_source.dart';
import 'package:capstone_2026/core/data/dto/studycafe/studycafe_detail_dto.dart';
import 'package:capstone_2026/core/data/mapper/studycafe/studycafe_detail_mapper.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudyCafeDataSourceImpl implements StudyCafeDataSource {
  final SupabaseClient _supabaseClient;
  final FirebaseFunctions _firebaseFunctions;

  const StudyCafeDataSourceImpl({
    required SupabaseClient supabaseClient,
    required FirebaseFunctions firebaseFunctions,
  }) : _supabaseClient = supabaseClient,
       _firebaseFunctions = firebaseFunctions;

  @override
  Future<StudyCafeDetail?> findDetailByStoreId(String storeId) async {
    final json = await _supabaseClient
        .from('studycafe_detail')
        .select()
        .eq('store_id', storeId)
        .maybeSingle();

    if (json == null) {
      return null;
    }
    return StudyCafeDetailDto.fromJson(json).toModel();
  }

  @override
  Future<StudyCafeDetail> upsertDetail(StudyCafeDetail detail) async {
    final callable = _firebaseFunctions.httpsCallable('saveStudyCafeDetail');
    final result = await callable.call({
      'storeId': detail.storeId,
      'layoutJson': {
        'seats': detail.seats.map((seat) => seat.toJson()).toList(),
        'elements': detail.elements.map((element) => element.toJson()).toList(),
      },
      'usageOptions': detail.usageOptions
          .map((option) => option.toJson())
          .toList(),
    });
    if (result.data is! Map) {
      throw StateError('Cloud Functions 응답 형식이 올바르지 않습니다.');
    }
    return StudyCafeDetailDto.fromJson(result.data).toModel();
  }

  @override
  Future<List<StudyCafeReservation>> findActiveReservationsByStoreId(
    String storeId,
  ) async {
    final now = DateTime.now().toIso8601String();
    final jsonList = await _supabaseClient
        .from('studycafe_reservations')
        .select()
        .eq('store_id', storeId)
        .eq('status', 'confirmed')
        .gt('end_at', now);

    return jsonList.map((json) => StudyCafeReservation.fromJson(json)).toList();
  }

  @override
  Stream<List<StudyCafeReservation>> watchActiveReservationsByStoreId(
    String storeId,
  ) {
    return _supabaseClient
        .from('studycafe_reservations')
        .stream(primaryKey: ['id'])
        .eq('store_id', storeId)
        .map(
          (jsonList) => jsonList
              .map((json) => StudyCafeReservation.fromJson(json))
              .where((reservation) => reservation.isActive)
              .toList(),
        );
  }

  @override
  Future<StudyCafeReservation> startUsage({
    required String storeId,
    required String userId,
    required String seatId,
    required int durationMinutes,
  }) async {
    final callable = _firebaseFunctions.httpsCallable('startStudyCafeUsage');
    final result = await callable.call({
      'storeId': storeId,
      'seatId': seatId,
      'durationMinutes': durationMinutes,
    });
    return StudyCafeReservation.fromJson(_asJsonMap(result.data));
  }

  @override
  Future<StudyCafeReservation> extendUsage({
    required String reservationId,
    required String userId,
    required int additionalMinutes,
  }) async {
    final callable = _firebaseFunctions.httpsCallable('extendStudyCafeUsage');
    final result = await callable.call({
      'reservationId': reservationId,
      'additionalMinutes': additionalMinutes,
    });
    return StudyCafeReservation.fromJson(_asJsonMap(result.data));
  }

  Map<String, Object?> _asJsonMap(Object? data) {
    if (data is Map) {
      return Map<String, Object?>.from(data);
    }
    throw StateError('Cloud Functions 응답 형식이 올바르지 않습니다.');
  }
}
