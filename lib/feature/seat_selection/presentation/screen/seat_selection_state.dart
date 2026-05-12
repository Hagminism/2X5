import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'seat_selection_state.freezed.dart';

@freezed
abstract class SeatSelectionState with _$SeatSelectionState {
  const factory SeatSelectionState({
    required String storeId,
    @Default(true) bool isLoading,
    String? errorMessage,
    @Default([]) List<StudyCafeSeat> seats,
    @Default([]) List<StudyCafeLayoutElement> elements,
    @Default([]) List<String> occupiedSeatIds,
    String? selectedSeatId,
  }) = _SeatSelectionState;
}
