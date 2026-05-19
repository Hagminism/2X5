import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_studycafe_seat_selection_action.freezed.dart';

@freezed
sealed class MapStudycafeSeatSelectionAction
    with _$MapStudycafeSeatSelectionAction {
  const factory MapStudycafeSeatSelectionAction.tapRetry() =
      MapStudycafeSeatTapRetry;

  const factory MapStudycafeSeatSelectionAction.tapSeat(String seatId) =
      MapStudycafeSeatTapSeat;

  const factory MapStudycafeSeatSelectionAction.tapConfirmSelection({
    required String seatId,
    required String seatLabel,
  }) = MapStudycafeSeatTapConfirmSelection;

  const factory MapStudycafeSeatSelectionAction.tapBack() =
      MapStudycafeSeatTapBack;
}
