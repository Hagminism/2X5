import 'dart:async';

import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/util/restaurant_booking_slot.dart';
import 'package:capstone_2026/core/presentation/util/user_facing_error_message.dart';
import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_action.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_event.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_state.dart';
import 'package:flutter/material.dart';

class ReservationViewModel extends ChangeNotifier {
  ReservationViewModel({
    required StoreRepository storeRepository,
    required ReservationRepository reservationRepository,
    required AuthRepository authRepository,
  }) : _storeRepository = storeRepository,
       _reservationRepository = reservationRepository,
       _authRepository = authRepository;

  final StoreRepository _storeRepository;
  final ReservationRepository _reservationRepository;
  final AuthRepository _authRepository;

  ReservationState _state = const ReservationState(storeId: '');

  ReservationState get state => _state;

  final StreamController<ReservationEvent> _eventController =
      StreamController<ReservationEvent>.broadcast();

  Stream<ReservationEvent> get eventStream => _eventController.stream;

  bool get canSubmit {
    if (_state.isLoading ||
        _state.isSubmitting ||
        _state.loadError != null ||
        _state.selectedDay == null ||
        _state.selectedTime == null) {
      return false;
    }

    final selectedSlot = _selectedSlot();
    return selectedSlot != null && selectedSlot.isSelectable;
  }

  int get maxGuestCount {
    final selectedSlot = _selectedSlot();
    if (selectedSlot == null) {
      return 1;
    }
    return selectedSlot.remainingGuestCount.clamp(1, 99);
  }

  Future<void> initialize(String storeId) async {
    final today = SalonBookingTime.seoulTodayCalendar();
    final todayDate = DateTime(today.year, today.month, today.day);
    _state = ReservationState(
      storeId: storeId,
      focusedDay: todayDate,
      selectedDay: todayDate,
    );
    notifyListeners();
    await _loadStoreAndSlots();
  }

  void onAction(ReservationAction action) {
    switch (action) {
      case ReservationTapRetry():
        unawaited(_loadStoreAndSlots());
        break;
      case ReservationSelectDay():
        unawaited(_selectDay(action.day));
        break;
      case ReservationSelectTime():
        _state = _state.copyWith(
          selectedTime: action.time,
          guestCount: 1,
          submitError: null,
        );
        notifyListeners();
        break;
      case ReservationTapIncreaseGuestCount():
        final next = (_state.guestCount + 1).clamp(1, maxGuestCount);
        _state = _state.copyWith(guestCount: next);
        notifyListeners();
        break;
      case ReservationTapDecreaseGuestCount():
        final next = (_state.guestCount - 1).clamp(1, maxGuestCount);
        _state = _state.copyWith(guestCount: next);
        notifyListeners();
        break;
      case ReservationTapSubmit():
        _requestSubmit();
        break;
      case ReservationConfirmSubmit():
        unawaited(_submit());
        break;
      case ReservationTapBack():
        break;
    }
  }

  bool isDaySelectable(DateTime day) {
    final store = _cachedStore;
    if (store == null) {
      return false;
    }

    final calendarDate = DateTime(day.year, day.month, day.day);
    return !RestaurantBookingSlot.isDateClosed(
      store: store,
      targetDate: calendarDate,
    );
  }

  Future<void> _loadStoreAndSlots() async {
    _state = _state.copyWith(
      isLoading: true,
      loadError: null,
      submitError: null,
    );
    notifyListeners();

    try {
      final store = await _storeRepository.getStoreById(_state.storeId);
      if (!store.isOnboarded) {
        throw StateError('입점하지 않은 매장입니다.');
      }

      _cachedStore = store;
      await _refreshSlots();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        loadError: userFacingErrorMessage(
          error,
          fallback: '예약 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> _selectDay(DateTime day) async {
    final calendarDate = DateTime(day.year, day.month, day.day);
    _state = _state.copyWith(
      selectedDay: calendarDate,
      focusedDay: calendarDate,
      selectedTime: null,
      guestCount: 1,
    );
    notifyListeners();
    await _refreshSlots();
  }

  Future<void> _refreshSlots() async {
    final store = _cachedStore;
    final selectedDay = _state.selectedDay;
    if (store == null || selectedDay == null) {
      return;
    }

    try {
      final slots = await _reservationRepository.getAvailabilityForDate(
        store: store,
        date: selectedDay,
      );
      _state = _state.copyWith(
        isLoading: false,
        slots: slots,
        loadError: null,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        loadError: userFacingErrorMessage(
          error,
          fallback: '예약 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
      notifyListeners();
    }
  }

  void _requestSubmit() {
    final selectedDay = _state.selectedDay;
    final selectedTime = _state.selectedTime;
    if (!canSubmit || selectedDay == null || selectedTime == null) {
      return;
    }

    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      _eventController.add(
        const ReservationEvent.showSnackBar('로그인이 필요합니다.'),
      );
      return;
    }

    _eventController.add(
      ReservationEvent.showConfirmDialog(
        bookingDate: selectedDay,
        bookingTime: selectedTime,
        guestCount: _state.guestCount,
      ),
    );
  }

  Future<void> _submit() async {
    final selectedDay = _state.selectedDay;
    final selectedTime = _state.selectedTime;
    if (!canSubmit || selectedDay == null || selectedTime == null) {
      return;
    }

    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null || uid.isEmpty) {
      _eventController.add(
        const ReservationEvent.showSnackBar('로그인이 필요합니다.'),
      );
      return;
    }

    _state = _state.copyWith(isSubmitting: true, submitError: null);
    notifyListeners();

    try {
      await _reservationRepository.createReservation(
        storeId: _state.storeId,
        bookingDate: selectedDay,
        bookingTime: selectedTime,
        guestCount: _state.guestCount,
      );

      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        ReservationEvent.showSuccessDialog(
          bookingDate: selectedDay,
          bookingTime: selectedTime,
          guestCount: _state.guestCount,
        ),
      );
    } catch (error) {
      _state = _state.copyWith(
        isSubmitting: false,
        submitError: userFacingErrorMessage(
          error,
          fallback: '예약에 실패했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
      notifyListeners();
      _eventController.add(
        ReservationEvent.showSnackBar(
          userFacingErrorMessage(
            error,
            fallback: '예약에 실패했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    }
  }

  Store? _cachedStore;

  RestaurantTimeSlot? _selectedSlot() {
    final selectedTime = _state.selectedTime;
    if (selectedTime == null) {
      return null;
    }
    for (final slot in _state.slots) {
      if (slot.time == selectedTime) {
        return slot;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
