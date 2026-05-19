import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_history_event.freezed.dart';

@freezed
sealed class ReservationHistoryEvent with _$ReservationHistoryEvent {
  const factory ReservationHistoryEvent.pop() = PopReservationHistoryScreen;

  const factory ReservationHistoryEvent.push(String location) =
      PushReservationHistoryRoute;

  const factory ReservationHistoryEvent.showSnackBar(String message) =
      ShowReservationHistorySnackBar;
}
