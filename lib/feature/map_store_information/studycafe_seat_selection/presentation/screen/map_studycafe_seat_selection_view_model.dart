import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_block_resolver.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_hold.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/core/presentation/util/user_facing_error_message.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_seat_selection/presentation/screen/map_studycafe_seat_selection_action.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_seat_selection/presentation/screen/map_studycafe_seat_selection_state.dart';
import 'package:flutter/foundation.dart';

class MapStudycafeSeatSelectionViewModel extends ChangeNotifier {
  MapStudycafeSeatSelectionViewModel({
    required StudyCafeRepository studyCafeRepository,
    required AuthRepository authRepository,
  }) : _studyCafeRepository = studyCafeRepository,
       _authRepository = authRepository,
       _state = const MapStudycafeSeatSelectionState(storeId: '');

  final StudyCafeRepository _studyCafeRepository;
  final AuthRepository _authRepository;

  String _storeId = '';

  MapStudycafeSeatSelectionState _state;

  MapStudycafeSeatSelectionState get state => _state;

  StreamSubscription<List<StudyCafeReservation>>? _reservationSubscription;
  StreamSubscription<List<StudyCafeSeatHold>>? _holdSubscription;

  List<StudyCafeReservation> _lastReservations = [];
  List<StudyCafeSeatHold> _lastHolds = [];

  String? get _currentUid => _authRepository.getCurrentUser()?.uid;

  Future<void> initialize(String storeId) async {
    await _reservationSubscription?.cancel();
    await _holdSubscription?.cancel();
    _reservationSubscription = null;
    _holdSubscription = null;
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
    await _holdSubscription?.cancel();
    _reservationSubscription = null;
    _holdSubscription = null;

    try {
      final detail = await _studyCafeRepository.getDetailByStoreId(_storeId);
      final normalizedDetail = detail ?? StudyCafeDetail.empty(_storeId);
      final activeReservations = await _studyCafeRepository
          .getActiveReservationsByStoreId(_storeId);
      final activeHolds = await _studyCafeRepository
          .getActiveSeatHoldsByStoreId(
            _storeId,
          );

      _lastReservations = activeReservations;
      _lastHolds = activeHolds;
      final occupiedSeatIds = StudyCafeSeatBlockResolver.displayBlockedSeatIds(
        reservations: _lastReservations,
        holds: _lastHolds,
        currentUserId: _currentUid,
      );

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
      _holdSubscription = _studyCafeRepository
          .watchActiveSeatHoldsByStoreId(_storeId)
          .listen(_onHoldsUpdated);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: userFacingErrorMessage(
          e,
          fallback: '좌석 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
      notifyListeners();
    }
  }

  void _onReservationsUpdated(List<StudyCafeReservation> reservations) {
    _lastReservations = reservations;
    _applyOccupiedFromSnapshots();
  }

  void _onHoldsUpdated(List<StudyCafeSeatHold> holds) {
    _lastHolds = holds;
    _applyOccupiedFromSnapshots();
  }

  void _applyOccupiedFromSnapshots() {
    final occupiedSeatIds = StudyCafeSeatBlockResolver.displayBlockedSeatIds(
      reservations: _lastReservations,
      holds: _lastHolds,
      currentUserId: _currentUid,
    );
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
    _holdSubscription?.cancel();
    super.dispose();
  }
}
