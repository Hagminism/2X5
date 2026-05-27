import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_schedule_exception.freezed.dart';

@freezed
abstract class StoreScheduleSlotOverride with _$StoreScheduleSlotOverride {
  const factory StoreScheduleSlotOverride({
    required String time,
    int? maxGuestCount,
    bool? isOpen,
  }) = _StoreScheduleSlotOverride;
}

@freezed
abstract class StoreScheduleException with _$StoreScheduleException {
  const factory StoreScheduleException({
    required String storeId,
    required DateTime exceptionDate,
    @Default(false) bool isClosed,
    String? openTime,
    String? closeTime,
    @Default([]) List<StoreScheduleSlotOverride> slotOverrides,
    DateTime? updatedAt,
  }) = _StoreScheduleException;
}
