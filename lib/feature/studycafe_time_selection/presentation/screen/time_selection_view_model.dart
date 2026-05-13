import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_block_resolver.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat_hold.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_action.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TimeSelectionViewModel extends ChangeNotifier {
  TimeSelectionViewModel({
    required StudyCafeRepository studyCafeRepository,
    required AuthRepository authRepository,
  }) : _studyCafeRepository = studyCafeRepository,
       _authRepository = authRepository,
       _state = TimeSelectionState(
         storeId: '',
         seatId: '',
         seatLabel: '',
         isLoadingDetail: true,
       );

  final StudyCafeRepository _studyCafeRepository;
  final AuthRepository _authRepository;

  TimeSelectionState _state;

  TimeSelectionState get state => _state;

  StreamSubscription<List<StudyCafeReservation>>? _reservationSubscription;
  StreamSubscription<List<StudyCafeSeatHold>>? _holdSubscription;

  String _routeStoreId = '';
  String _routeSeatId = '';

  List<StudyCafeReservation> _lastReservationSnapshot = [];
  List<StudyCafeSeatHold> _lastHoldSnapshot = [];

  String? _activeHoldId;
  bool _submitSucceeded = false;

  bool get canSubmit {
    final TimeSelectionState s = _state;
    return !s.isLoadingDetail &&
        s.loadError == null &&
        !s.seatTakenByOther &&
        s.selectedDurationMinutes != null &&
        s.usageOptions.isNotEmpty &&
        !s.isSubmitting;
  }

  void initialize({
    required String storeId,
    required String seatId,
    required String seatLabel,
  }) async {
    _routeStoreId = storeId;
    _routeSeatId = seatId;
    _activeHoldId = null;
    _submitSucceeded = false;

    await _reservationSubscription?.cancel();
    await _holdSubscription?.cancel();
    _reservationSubscription = null;
    _holdSubscription = null;

    _state = TimeSelectionState(
      storeId: storeId,
      seatId: seatId,
      seatLabel: seatLabel,
      isLoadingDetail: true,
      loadError: null,
      seatTakenByOther: false,
      usageOptions: const [],
      selectedDurationMinutes: null,
      isSubmitting: false,
      submitError: null,
    );
    notifyListeners();

    _listenReservations(storeId);
    _listenSeatHolds(storeId);

    await _loadDetail();
    await _primeSeatConflictCheck();
    await _tryAcquireHold();
  }

  void onAction(TimeSelectionAction action) {
    switch (action) {
      case TapRetry():
        unawaited(_retryAfterFailure());
        break;
      case TapSelectUsageOption(:final durationMinutes):
        _selectDuration(durationMinutes);
        break;
      case TapBack():
      case TapSubmit():
        break;
    }
  }

  Future<void> _retryAfterFailure() async {
    await _loadDetail();
    await _primeSeatConflictCheck();
    await _tryAcquireHold();
    notifyListeners();
  }

  Future<void> _loadDetail() async {
    _state = _state.copyWith(
      isLoadingDetail: true,
      loadError: null,
      submitError: null,
    );
    notifyListeners();

    try {
      final detail = await _studyCafeRepository.getDetailByStoreId(
        _routeStoreId,
      );
      final options =
          (detail?.usageOptions ?? [])
              .where((StudyCafeUsageOption o) => o.isEnabled)
              .toList()
            ..sort(
              (StudyCafeUsageOption a, StudyCafeUsageOption b) =>
                  a.durationMinutes.compareTo(b.durationMinutes),
            );

      final selected = _state.selectedDurationMinutes;
      final bool stillValid =
          selected != null &&
          options.any(
            (StudyCafeUsageOption o) => o.durationMinutes == selected,
          );

      _state = _state.copyWith(
        isLoadingDetail: false,
        usageOptions: options,
        selectedDurationMinutes: stillValid ? selected : null,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        loadError: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> _primeSeatConflictCheck() async {
    _lastReservationSnapshot = await _studyCafeRepository
        .getActiveReservationsByStoreId(_routeStoreId);
    _lastHoldSnapshot = await _studyCafeRepository.getActiveSeatHoldsByStoreId(
      _routeStoreId,
    );
    _recomputeSeatTakenFromSnapshots();
  }

  void _listenReservations(String storeId) {
    _reservationSubscription = _studyCafeRepository
        .watchActiveReservationsByStoreId(storeId)
        .listen((List<StudyCafeReservation> list) {
          _lastReservationSnapshot = list;
          _recomputeSeatTakenFromSnapshots();
          notifyListeners();
        });
  }

  void _listenSeatHolds(String storeId) {
    _holdSubscription = _studyCafeRepository
        .watchActiveSeatHoldsByStoreId(storeId)
        .listen((List<StudyCafeSeatHold> list) {
          _lastHoldSnapshot = list;
          _recomputeSeatTakenFromSnapshots();
          notifyListeners();
        });
  }

  void _recomputeSeatTakenFromSnapshots() {
    final User? user = _authRepository.getCurrentUser();
    final String? uid = user?.uid;
    final bool taken = StudyCafeSeatBlockResolver.isRouteSeatTakenByOther(
      routeSeatId: _routeSeatId,
      reservations: _lastReservationSnapshot,
      holds: _lastHoldSnapshot,
      currentUserId: uid,
    );
    _state = _state.copyWith(seatTakenByOther: taken);
  }

  Future<void> _tryAcquireHold() async {
    final User? user = _authRepository.getCurrentUser();
    if (user == null || user.uid.isEmpty) {
      _state = _state.copyWith(
        loadError: '로그인이 필요합니다.',
        seatTakenByOther: false,
      );
      notifyListeners();
      return;
    }
    try {
      final hold = await _studyCafeRepository.acquireSeatHold(
        storeId: _routeStoreId,
        seatId: _routeSeatId,
        holdMinutes: 15,
      );
      _activeHoldId = hold.id;
      _state = _state.copyWith(loadError: null);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        loadError: e.toString(),
        seatTakenByOther: true,
      );
      notifyListeners();
    }
  }

  void _selectDuration(int durationMinutes) {
    final bool exists = _state.usageOptions.any(
      (StudyCafeUsageOption o) => o.durationMinutes == durationMinutes,
    );
    if (!exists) {
      return;
    }
    _state = _state.copyWith(
      selectedDurationMinutes: durationMinutes,
      submitError: null,
    );
    notifyListeners();
  }

  /// 연장(extend)은 기존 예약이 있는 사용자가 [StudyCafeRepository.extendUsage]로 종료 시각만 늘리는 별도 화면/VM에서 다루면 됩니다.
  Future<bool> submitUsage() async {
    if (!canSubmit) {
      return false;
    }
    final int durationMinutes = _state.selectedDurationMinutes!;

    _state = _state.copyWith(isSubmitting: true, submitError: null);
    notifyListeners();

    try {
      await _studyCafeRepository.startUsage(
        storeId: _routeStoreId,
        seatId: _routeSeatId,
        durationMinutes: durationMinutes,
      );
      _submitSucceeded = true;
      return true;
    } catch (e) {
      _state = _state.copyWith(submitError: e.toString());
      return false;
    } finally {
      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
    }
  }

  StudyCafeUsageOption? selectedUsageOption() {
    final int? selected = _state.selectedDurationMinutes;
    if (selected == null) {
      return null;
    }
    for (final StudyCafeUsageOption o in _state.usageOptions) {
      if (o.durationMinutes == selected) {
        return o;
      }
    }
    return null;
  }

  @override
  void dispose() {
    final String? holdIdToRelease = _submitSucceeded ? null : _activeHoldId;
    _reservationSubscription?.cancel();
    _holdSubscription?.cancel();
    super.dispose();
    if (holdIdToRelease != null && holdIdToRelease.isNotEmpty) {
      unawaited(
        _studyCafeRepository.releaseSeatHold(holdId: holdIdToRelease),
      );
    }
  }
}
