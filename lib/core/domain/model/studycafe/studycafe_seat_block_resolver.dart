import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_hold.dart';

/// 예약·홀드를 합쳐 좌석 맵에서 막힌 seat id 목록을 만든다.
/// [currentUserId]가 null이면 타인 홀드만 막지 않고, 내 홀드도 막는다.
abstract final class StudyCafeSeatBlockResolver {
  static List<String> displayBlockedSeatIds({
    required List<StudyCafeReservation> reservations,
    required List<StudyCafeSeatHold> holds,
    String? currentUserId,
  }) {
    final fromRes = reservations
        .where((StudyCafeReservation r) => r.isActive)
        .map((StudyCafeReservation r) => r.seatId)
        .toSet();
    final fromHolds = <String>{};
    for (final StudyCafeSeatHold h in holds) {
      if (!h.isActive) {
        continue;
      }
      if (currentUserId != null && h.userId == currentUserId) {
        continue;
      }
      fromHolds.add(h.seatId);
    }
    return {...fromRes, ...fromHolds}.toList();
  }

  static bool isRouteSeatTakenByOther({
    required String routeSeatId,
    required List<StudyCafeReservation> reservations,
    required List<StudyCafeSeatHold> holds,
    String? currentUserId,
  }) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }
    for (final StudyCafeReservation r in reservations) {
      if (!r.isActive) {
        continue;
      }
      if (r.seatId != routeSeatId) {
        continue;
      }
      if (r.userId != currentUserId) {
        return true;
      }
    }
    for (final StudyCafeSeatHold h in holds) {
      if (!h.isActive) {
        continue;
      }
      if (h.seatId != routeSeatId) {
        continue;
      }
      if (h.userId != currentUserId) {
        return true;
      }
    }
    return false;
  }
}
