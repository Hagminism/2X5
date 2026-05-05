import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_reservations_event.freezed.dart';

@freezed
sealed class PartnerReservationsEvent with _$PartnerReservationsEvent {
  const factory PartnerReservationsEvent.showMessage(String message) =
      ShowMessage;

  const factory PartnerReservationsEvent.openDatePicker(DateTime? selectedDate) =
      OpenDatePicker;
}
