import 'package:capstone_2026/core/data/dto/studycafe/studycafe_seat_hold_dto.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_hold.dart';

extension StudyCafeSeatHoldDtoMapper on StudyCafeSeatHoldDto {
  StudyCafeSeatHold toModel() {
    return StudyCafeSeatHold(
      id: id ?? '',
      storeId: storeId ?? '',
      userId: userId ?? '',
      seatId: seatId ?? '',
      expiresAt: _parseDateTime(expiresAt),
      status: status ?? 'active',
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
