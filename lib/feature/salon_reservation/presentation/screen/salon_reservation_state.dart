import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation_state.freezed.dart';

@freezed
abstract class SalonReservationSlot with _$SalonReservationSlot {
  const SalonReservationSlot._();

  const factory SalonReservationSlot({
    required DateTime startAt,
    @Default(false) bool isReserved,
    @Default(false) bool isPast,
  }) = _SalonReservationSlot;

  bool get isEnabled => !isReserved && !isPast;
}

@freezed
abstract class SalonReservationState with _$SalonReservationState {
  const factory SalonReservationState({
    required String storeId,
    @Default(true) bool isLoading,
    String? loadError,
    @Default(30) int reservationSlotMinutes,
    @Default([]) List<SalonDesigner> designers,
    @Default([]) List<SalonService> services,
    @Default([]) List<SalonDesignerSchedule> schedules,
    @Default([]) List<SalonReservationSlot> slots,
    String? selectedDesignerId,
    @Default([]) List<String> selectedServiceIds,
    DateTime? selectedDate,
    DateTime? selectedStartAt,
    @Default(false) bool isSubmitting,
    String? submitError,
  }) = _SalonReservationState;
}
