import 'package:freezed_annotation/freezed_annotation.dart';

part 'seat_selection_action.freezed.dart';

@freezed
sealed class SeatSelectionAction with _$SeatSelectionAction {
  const factory SeatSelectionAction.tapRetry() = TapRetry;

  const factory SeatSelectionAction.tapSeat(String seatId) = TapSeat;

  const factory SeatSelectionAction.tapConfirmSelection({
    required String seatId,
    required String seatLabel,
  }) = TapConfirmSelection;

  const factory SeatSelectionAction.tapBack() = TapBack;
}
