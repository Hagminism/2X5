import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required DateTime bookingDate,
    required String bookingTime,
    required int guestCount,
    required DateTime createdAt,
    String? customerRequest,
    required ReservationStatus status,
    required int totalPrice,
    required DateTime updatedAt,
    required String storeId,
    required String userId,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, Object?> json) =>
      _$ReservationFromJson(json);
}
