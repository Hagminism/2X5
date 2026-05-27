import 'package:capstone_2026/core/data/dto/reservation/store_reservation_slot_default_dto.dart';
import 'package:capstone_2026/core/data/dto/reservation/store_schedule_exception_dto.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_reservation_slot_default.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_schedule_exception.dart';

extension StoreReservationSlotDefaultDtoMapper
    on StoreReservationSlotDefaultDto {
  StoreReservationSlotDefault toModel() {
    return StoreReservationSlotDefault(
      storeId: storeId ?? '',
      slotTime: slotTime ?? '',
      maxGuestCount: maxGuestCount ?? 1,
      isOpen: isOpen ?? true,
      updatedAt: _parseDateTime(updatedAt),
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

extension StoreReservationSlotDefaultToDtoMapper
    on StoreReservationSlotDefault {
  StoreReservationSlotDefaultDto toDto() {
    return StoreReservationSlotDefaultDto(
      storeId: storeId,
      slotTime: slotTime,
      maxGuestCount: maxGuestCount,
      isOpen: isOpen,
      updatedAt: updatedAt?.toIso8601String(),
    );
  }
}

extension StoreScheduleExceptionDtoMapper on StoreScheduleExceptionDto {
  StoreScheduleException toModel() {
    return StoreScheduleException(
      storeId: storeId ?? '',
      exceptionDate: _parseDate(exceptionDate),
      isClosed: isClosed ?? false,
      openTime: _normalizeTime(openTime),
      closeTime: _normalizeTime(closeTime),
      slotOverrides: (slotOverrides ?? [])
          .map(
            (json) => StoreScheduleSlotOverride(
              time: json['time']?.toString() ?? '',
              maxGuestCount: (json['max_guest_count'] as num?)?.toInt(),
              isOpen: json['is_open'] as bool?,
            ),
          )
          .where((override) => override.time.isNotEmpty)
          .toList(),
      updatedAt: _parseDateTime(updatedAt),
    );
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String? _normalizeTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parts = value.split(':');
    if (parts.length < 2) {
      return value;
    }
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }
}

extension StoreScheduleExceptionToDtoMapper on StoreScheduleException {
  StoreScheduleExceptionDto toDto() {
    return StoreScheduleExceptionDto(
      storeId: storeId,
      exceptionDate:
          '${exceptionDate.year.toString().padLeft(4, '0')}-'
          '${exceptionDate.month.toString().padLeft(2, '0')}-'
          '${exceptionDate.day.toString().padLeft(2, '0')}',
      isClosed: isClosed,
      openTime: openTime,
      closeTime: closeTime,
      slotOverrides: slotOverrides
          .map(
            (override) => {
              'time': override.time,
              if (override.maxGuestCount != null)
                'max_guest_count': override.maxGuestCount,
              if (override.isOpen != null) 'is_open': override.isOpen,
            },
          )
          .toList(),
      updatedAt: updatedAt?.toIso8601String(),
    );
  }
}
