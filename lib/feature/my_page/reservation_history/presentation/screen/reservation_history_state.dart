import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_history_state.freezed.dart';

@freezed
abstract class ReservationHistoryState with _$ReservationHistoryState {
  const factory ReservationHistoryState({
    @Default(false) bool isLoading,
    @Default(<UserReservationHistoryItem>[])
    List<UserReservationHistoryItem> items,
  }) = _ReservationHistoryState;
}
