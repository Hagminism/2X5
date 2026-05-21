import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_state.dart';

StudyCafeSeat? selectedSeatForState(SeatSelectionState state) {
  final selectedSeatId = state.selectedSeatId;
  if (selectedSeatId == null) {
    return null;
  }
  for (final StudyCafeSeat seat in state.seats) {
    if (seat.seatId == selectedSeatId) {
      return seat;
    }
  }
  return null;
}

String seatLabelForDisplay(StudyCafeSeat seat) {
  final trimmed = seat.label.trim();
  return trimmed.isNotEmpty ? trimmed : seat.seatId;
}
