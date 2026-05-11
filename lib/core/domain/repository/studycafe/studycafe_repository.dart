import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';

abstract interface class StudyCafeRepository {
  Future<StudyCafeDetail?> getDetailByStoreId(String storeId);

  Future<StudyCafeDetail> getMyStoreDetail();

  Future<StudyCafeDetail> saveMyStoreDetail(StudyCafeDetail detail);

  Future<List<StudyCafeReservation>> getActiveReservationsByStoreId(
    String storeId,
  );

  Stream<List<StudyCafeReservation>> watchActiveReservationsByStoreId(
    String storeId,
  );

  Future<StudyCafeReservation> startUsage({
    required String storeId,
    required String seatId,
    required int durationMinutes,
  });

  Future<StudyCafeReservation> extendUsage({
    required String reservationId,
    required int additionalMinutes,
  });
}
