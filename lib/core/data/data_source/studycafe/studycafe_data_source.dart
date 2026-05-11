import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';

abstract interface class StudyCafeDataSource {
  Future<StudyCafeDetail?> findDetailByStoreId(String storeId);

  Future<StudyCafeDetail> upsertDetail(StudyCafeDetail detail);

  Future<List<StudyCafeReservation>> findActiveReservationsByStoreId(
    String storeId,
  );

  Stream<List<StudyCafeReservation>> watchActiveReservationsByStoreId(
    String storeId,
  );

  Future<StudyCafeReservation> startUsage({
    required String storeId,
    required String userId,
    required String seatId,
    required int durationMinutes,
  });

  Future<StudyCafeReservation> extendUsage({
    required String reservationId,
    required String userId,
    required int additionalMinutes,
  });
}
