import 'package:capstone_2026/core/data/dto/reservation/reservation_dto.dart';
import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';

extension ReservationDtoMapper on ReservationDto {
  Reservation toModel() {
    return Reservation(
      id: id ?? '',
      bookingDate: _parseDateTime(bookingDate),
      bookingTime: bookingTime ?? '',
      guestCount: guestCount ?? 1,
      createdAt: _parseDateTime(createdAt),
      customerRequest: customerRequest,
      status:
          ReservationStatus.fromDbValue(status) ?? ReservationStatus.pending,
      totalPrice: totalPrice ?? 0,
      updatedAt: _parseDateTime(updatedAt),
      storeId: storeId ?? '',
      userId: userId ?? '',
    );
  }

  DateTime _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.now();
    }

    return DateTime.tryParse(value) ?? DateTime.now();
  }
}

extension ReservationToDtoMapper on Reservation {
  ReservationDto toDto() {
    return ReservationDto(
      id: id,
      bookingDate: bookingDate.toIso8601String().split('T').first,
      bookingTime: bookingTime,
      guestCount: guestCount,
      createdAt: createdAt.toIso8601String(),
      customerRequest: customerRequest,
      status: status.dbValue,
      totalPrice: totalPrice,
      updatedAt: updatedAt.toIso8601String(),
      storeId: storeId,
      userId: userId,
    );
  }
}
