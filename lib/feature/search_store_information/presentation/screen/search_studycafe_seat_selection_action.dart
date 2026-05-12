import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_studycafe_seat_selection_action.freezed.dart';

@freezed
sealed class SearchStudycafeSeatSelectionAction
    with _$SearchStudycafeSeatSelectionAction {
  const factory SearchStudycafeSeatSelectionAction.tapRetry() =
      SearchStudycafeSeatTapRetry;

  const factory SearchStudycafeSeatSelectionAction.tapSeat(String seatId) =
      SearchStudycafeSeatTapSeat;

  const factory SearchStudycafeSeatSelectionAction.tapConfirmSelection({
    required String seatId,
    required String seatLabel,
  }) = SearchStudycafeSeatTapConfirmSelection;

  const factory SearchStudycafeSeatSelectionAction.tapBack() =
      SearchStudycafeSeatTapBack;
}
