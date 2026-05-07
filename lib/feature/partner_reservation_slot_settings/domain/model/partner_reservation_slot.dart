import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_congestion_level.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservation_slot.freezed.dart';
part 'partner_reservation_slot.g.dart';

@freezed
abstract class PartnerReservationSlot with _$PartnerReservationSlot {
  const PartnerReservationSlot._();

  const factory PartnerReservationSlot({
    required String time,
    required int maxTeamCount,
    required int reservedTeamCount,
    required bool isOpen,
  }) = _PartnerReservationSlot;

  factory PartnerReservationSlot.fromJson(Map<String, Object?> json) =>
      _$PartnerReservationSlotFromJson(json);

  int get remainingTeamCount => (maxTeamCount - reservedTeamCount).clamp(0, 9999);

  int get occupancyPercent {
    if (maxTeamCount <= 0) {
      return 0;
    }
    final ratio = (reservedTeamCount / maxTeamCount) * 100;
    return ratio.clamp(0, 100).round();
  }

  ReservationCongestionLevel get congestionLevel {
    if (!isOpen) {
      return ReservationCongestionLevel.closed;
    }

    final occupancy = occupancyPercent;
    if (occupancy >= 100) {
      return ReservationCongestionLevel.closed;
    }
    if (occupancy >= 76) {
      return ReservationCongestionLevel.saturated;
    }
    if (occupancy >= 51) {
      return ReservationCongestionLevel.busy;
    }
    if (occupancy >= 26) {
      return ReservationCongestionLevel.normal;
    }
    return ReservationCongestionLevel.relaxed;
  }
}
