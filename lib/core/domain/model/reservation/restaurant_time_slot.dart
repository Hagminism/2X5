import 'package:capstone_2026/core/domain/model/enum/reservation_congestion_level.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_time_slot.freezed.dart';

@freezed
abstract class RestaurantTimeSlot with _$RestaurantTimeSlot {
  const RestaurantTimeSlot._();

  const factory RestaurantTimeSlot({
    required String time,
    required int maxGuestCount,
    required int reservedGuestCount,
    required bool isOpen,
    required bool isSelectable,
  }) = _RestaurantTimeSlot;

  int get remainingGuestCount =>
      (maxGuestCount - reservedGuestCount).clamp(0, 9999);

  int get occupancyPercent {
    if (maxGuestCount <= 0) {
      return 0;
    }
    final ratio = (reservedGuestCount / maxGuestCount) * 100;
    return ratio.clamp(0, 100).round();
  }

  ReservationCongestionLevel get congestionLevel {
    if (!isOpen || !isSelectable || remainingGuestCount <= 0) {
      return ReservationCongestionLevel.closed;
    }

    final occupancy = occupancyPercent;
    if (occupancy >= 100) {
      return ReservationCongestionLevel.closed;
    }
    if (occupancy >= 75) {
      return ReservationCongestionLevel.saturated;
    }
    if (occupancy >= 50) {
      return ReservationCongestionLevel.busy;
    }
    if (occupancy >= 25) {
      return ReservationCongestionLevel.normal;
    }
    return ReservationCongestionLevel.relaxed;
  }
}
