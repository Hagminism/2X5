import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation_confirm_state.freezed.dart';

@freezed
abstract class SalonReservationConfirmState with _$SalonReservationConfirmState {
  const factory SalonReservationConfirmState({
    @Default(false) bool isLoading,
    @Default('') String storeId,
    @Default('') String designerId,
    @Default([]) List<String> selectedServiceIds,
    @Default('') String selectedDateTime,
    Store? store,
    SalonDesigner? designer,
    @Default([]) List<SalonService> services,
    String? submitError,
    @Default(false) bool isSubmitting,
  }) = _SalonReservationConfirmState;
}
