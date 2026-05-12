import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_reservation.dart';
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
  })  : _studyCafeRepository = studyCafeRepository,
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

  String _routeStoreId = '';
  String _routeSeatId = '';

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

    await _reservationSubscription?.cancel();
    _reservationSubscription = null;

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

    await _loadDetail();
    _listenReservations(storeId);
  }

  void onAction(TimeSelectionAction action) {
    switch (action) {
      case TapRetry():
        unawaited(_loadDetail());
        break;
      case TapSelectUsageOption(:final durationMinutes):
        _selectDuration(durationMinutes);
        break;
      case TapBack():
      case TapSubmit():
        break;
    }
  }

  Future<void> _loadDetail() async {
    _state = _state.copyWith(
      isLoadingDetail: true,
      loadError: null,
      submitError: null,
    );
    notifyListeners();

    try {
      final detail =
          await _studyCafeRepository.getDetailByStoreId(_routeStoreId);
      final options = (detail?.usageOptions ?? [])
          .where((StudyCafeUsageOption o) => o.isEnabled)
          .toList()
        ..sort(
          (StudyCafeUsageOption a, StudyCafeUsageOption b) =>
              a.durationMinutes.compareTo(b.durationMinutes),
        );

      final selected = _state.selectedDurationMinutes;
      final bool stillValid = selected != null &&
          options.any(
            (StudyCafeUsageOption o) => o.durationMinutes == selected,
          );

      _state = _state.copyWith(
        isLoadingDetail: false,
        usageOptions: options,
        selectedDurationMinutes: stillValid ? selected : null,
      );
      _recomputeSeatTaken(_lastReservationSnapshot);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoadingDetail: false,
        loadError: e.toString(),
      );
      notifyListeners();
    }
  }

  List<StudyCafeReservation> _lastReservationSnapshot = [];

  void _listenReservations(String storeId) {
    _reservationSubscription = _studyCafeRepository
        .watchActiveReservationsByStoreId(storeId)
        .listen((List<StudyCafeReservation> list) {
      _lastReservationSnapshot = list;
      _recomputeSeatTaken(list);
      notifyListeners();
    });
  }

  void _recomputeSeatTaken(List<StudyCafeReservation> reservations) {
    final User? user = _authRepository.getCurrentUser();
    final String? uid = user?.uid;
    if (uid == null || uid.isEmpty) {
      _state = _state.copyWith(seatTakenByOther: false);
      return;
    }
    var takenByOther = false;
    for (final StudyCafeReservation r in reservations) {
      if (!r.isActive) {
        continue;
      }
      if (r.seatId != _routeSeatId) {
        continue;
      }
      if (r.userId != uid) {
        takenByOther = true;
        break;
      }
    }
    _state = _state.copyWith(seatTakenByOther: takenByOther);
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
    _reservationSubscription?.cancel();
    super.dispose();
  }
}
