import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservation_slot_settings_state.freezed.dart';

@freezed
abstract class PartnerReservationSlotSettingsState
    with _$PartnerReservationSlotSettingsState {
  const PartnerReservationSlotSettingsState._();

  const factory PartnerReservationSlotSettingsState({
    @Default('') String storeId,
    @Default(30) int reservationSlotMinutes,
    required DateTime selectedDate,
    @Default([]) List<PartnerReservationSlot> slots,
    @Default(false) bool isClosed,
    String? exceptionOpenTime,
    String? exceptionCloseTime,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? loadError,
    String? saveMessage,
  }) = _PartnerReservationSlotSettingsState;

  factory PartnerReservationSlotSettingsState.initial() {
    final now = DateTime.now();
    return PartnerReservationSlotSettingsState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }
}
