import 'package:capstone_2026/core/data/dto/studycafe/studycafe_reservation_dto.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';

extension StudyCafeReservationDtoMapper on StudyCafeReservationDto {
  StudyCafeReservation toModel() {
    return StudyCafeReservation(
      id: id ?? '',
      storeId: storeId ?? '',
      userId: userId ?? '',
      seatId: seatId ?? '',
      durationMinutes: durationMinutes ?? 0,
      startAt: _parseDateTime(startAt),
      endAt: _parseDateTime(endAt),
      status: status ?? 'confirmed',
      createdAt: _parseOptionalDateTime(createdAt),
      updatedAt: _parseOptionalDateTime(updatedAt),
    );
  }

  DateTime _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _parseOptionalDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

extension StudyCafeReservationToDtoMapper on StudyCafeReservation {
  StudyCafeReservationDto toDto() {
    return StudyCafeReservationDto(
      id: id,
      storeId: storeId,
      userId: userId,
      seatId: seatId,
      durationMinutes: durationMinutes,
      startAt: startAt.toIso8601String(),
      endAt: endAt.toIso8601String(),
      status: status,
      createdAt: createdAt?.toIso8601String(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }
}
