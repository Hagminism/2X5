import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_hold.dart';

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

  Future<List<StudyCafeSeatHold>> getActiveSeatHoldsByStoreId(String storeId);

  Stream<List<StudyCafeSeatHold>> watchActiveSeatHoldsByStoreId(String storeId);

  Future<StudyCafeSeatHold> acquireSeatHold({
    required String storeId,
    required String seatId,
    int holdMinutes = 10,
  });

  Future<void> releaseSeatHold({required String holdId});

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
