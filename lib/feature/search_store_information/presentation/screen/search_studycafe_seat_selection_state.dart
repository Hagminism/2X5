import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_studycafe_seat_selection_state.freezed.dart';

@freezed
abstract class SearchStudycafeSeatSelectionState
    with _$SearchStudycafeSeatSelectionState {
  const factory SearchStudycafeSeatSelectionState({
    required String storeId,
    @Default(true) bool isLoading,
    String? errorMessage,
    @Default([]) List<StudyCafeSeat> seats,
    @Default([]) List<StudyCafeLayoutElement> elements,
    @Default([]) List<String> occupiedSeatIds,
    String? selectedSeatId,
  }) = _SearchStudycafeSeatSelectionState;
}
