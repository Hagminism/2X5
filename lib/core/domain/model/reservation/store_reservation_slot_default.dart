import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_reservation_slot_default.freezed.dart';

@freezed
abstract class StoreReservationSlotDefault with _$StoreReservationSlotDefault {
  const factory StoreReservationSlotDefault({
    required String storeId,
    required String slotTime,
    required int maxGuestCount,
    required bool isOpen,
    DateTime? updatedAt,
  }) = _StoreReservationSlotDefault;
}
