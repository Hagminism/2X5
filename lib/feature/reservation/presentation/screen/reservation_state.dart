import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_state.freezed.dart';

@freezed
abstract class ReservationState with _$ReservationState {
  const factory ReservationState({
    required String storeId,
    @Default(true) bool isLoading,
    String? loadError,
    DateTime? focusedDay,
    DateTime? selectedDay,
    String? selectedTime,
    @Default(1) int guestCount,
    @Default('') String customerRequest,
    @Default([]) List<RestaurantTimeSlot> slots,
    @Default(false) bool isSubmitting,
    String? submitError,
  }) = _ReservationState;
}
