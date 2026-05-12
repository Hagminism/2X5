import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_action.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_state.dart';
import 'package:flutter/foundation.dart';

class MapStudycafeSeatSelectionViewModel extends ChangeNotifier {
  MapStudycafeSeatSelectionViewModel({
    required StudyCafeRepository studyCafeRepository,
  })  : _studyCafeRepository = studyCafeRepository,
        _state = const MapStudycafeSeatSelectionState(storeId: '');

  final StudyCafeRepository _studyCafeRepository;

  String _storeId = '';

  MapStudycafeSeatSelectionState _state;

  MapStudycafeSeatSelectionState get state => _state;

  StreamSubscription<List<StudyCafeReservation>>? _reservationSubscription;

  Future<void> initialize(String storeId) async {
    await _reservationSubscription?.cancel();
    _reservationSubscription = null;
    _storeId = storeId;
    _state = MapStudycafeSeatSelectionState(storeId: storeId);
    await _initialize();
  }

  void onAction(MapStudycafeSeatSelectionAction action) {
    switch (action) {
      case MapStudycafeSeatTapRetry():
        unawaited(_initialize());
        break;
      case MapStudycafeSeatTapSeat(:final seatId):
        _onSeatTapped(seatId);
        break;
      case MapStudycafeSeatTapConfirmSelection():
        break;
      case MapStudycafeSeatTapBack():
        break;
    }
  }

  Future<void> _initialize() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    await _reservationSubscription?.cancel();
    _reservationSubscription = null;

    try {
      final detail = await _studyCafeRepository.getDetailByStoreId(_storeId);
      final normalizedDetail = detail ?? StudyCafeDetail.empty(_storeId);
      final activeReservations = await _studyCafeRepository
          .getActiveReservationsByStoreId(_storeId);

      final occupiedSeatIds = activeReservations
          .map((e) => e.seatId)
          .toSet()
          .toList();

      _state = _state.copyWith(
        isLoading: false,
        seats: normalizedDetail.seats,
        elements: normalizedDetail.elements,
        occupiedSeatIds: occupiedSeatIds,
        selectedSeatId: _clearSelectionIfOccupied(
          _state.selectedSeatId,
          occupiedSeatIds,
        ),
      );
      notifyListeners();

      _reservationSubscription = _studyCafeRepository
          .watchActiveReservationsByStoreId(_storeId)
          .listen(_onReservationsUpdated);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  void _onReservationsUpdated(List<StudyCafeReservation> reservations) {
    final occupiedSeatIds =
        reservations.map((StudyCafeReservation e) => e.seatId).toSet().toList();
    final selectedId = _state.selectedSeatId;
    _state = _state.copyWith(
      occupiedSeatIds: occupiedSeatIds,
      selectedSeatId: _clearSelectionIfOccupied(selectedId, occupiedSeatIds),
    );
    notifyListeners();
  }

  String? _clearSelectionIfOccupied(
    String? selectedSeatId,
    List<String> occupiedSeatIds,
  ) {
    if (selectedSeatId == null) {
      return null;
    }
    return occupiedSeatIds.contains(selectedSeatId) ? null : selectedSeatId;
  }

  void _onSeatTapped(String seatId) {
    StudyCafeSeat? seat;
    for (final StudyCafeSeat s in _state.seats) {
      if (s.seatId == seatId) {
        seat = s;
        break;
      }
    }
    if (seat == null) {
      return;
    }
    final isOccupied =
        _state.occupiedSeatIds.contains(seat.seatId) || !seat.isEnabled;
    if (isOccupied) {
      return;
    }
    _state = _state.copyWith(selectedSeatId: seat.seatId);
    notifyListeners();
  }

  @override
  void dispose() {
    _reservationSubscription?.cancel();
    super.dispose();
  }
}
