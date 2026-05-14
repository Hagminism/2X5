import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_state.dart';
import 'package:flutter/foundation.dart';

class SalonReservationViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;
  final StoreRepository _storeRepository;

  SalonReservationViewModel({
    required SalonRepository salonRepository,
    required StoreRepository storeRepository,
  }) : _salonRepository = salonRepository,
       _storeRepository = storeRepository,
       _state = const SalonReservationState(storeId: '');

  SalonReservationState _state;

  SalonReservationState get state => _state;

  List<SalonReservation> _reservations = [];

  bool get canSubmit {
    final selectedStartAt = _state.selectedStartAt;
    if (selectedStartAt == null) {
      return false;
    }
    final bool enabledSlot = _state.slots.any(
      (slot) => _sameUtcMinute(slot.startAt, selectedStartAt) && slot.isEnabled,
    );
    return !_state.isLoading &&
        !_state.isSubmitting &&
        _state.loadError == null &&
        _state.selectedDesignerId != null &&
        _state.selectedServiceIds.isNotEmpty &&
        enabledSlot;
  }

  Future<void> initialize(String storeId, {String? initialDesignerId}) async {
    final today = SalonBookingTime.seoulTodayCalendar();
    _state = SalonReservationState(
      storeId: storeId,
      selectedDate: DateTime(today.year, today.month, today.day),
    );
    notifyListeners();
    await _loadInitialData(initialDesignerId: initialDesignerId);
  }

  void onAction(SalonReservationAction action) {
    switch (action) {
      case SalonReservationTapRetry():
        unawaited(_loadInitialData(initialDesignerId: null));
        break;
      case SalonReservationSelectDesigner(:final designerId):
        unawaited(_selectDesigner(designerId));
        break;
      case SalonReservationSelectService(:final serviceId):
        final newIds = List<String>.from(_state.selectedServiceIds);
        if (newIds.contains(serviceId)) {
          newIds.remove(serviceId);
        } else {
          newIds.add(serviceId);
        }
        _state = _state.copyWith(
          selectedServiceIds: newIds,
          submitError: null,
        );
        notifyListeners();
        break;
      case SalonReservationSelectDate(:final date):
        unawaited(_selectDate(date));
        break;
      case SalonReservationSelectSlot(:final startAt):
        _selectSlot(startAt);
        break;
      case SalonReservationTapBack():
      case SalonReservationTapSubmit():
        break;
    }
  }

  // submitReservation() is removed as it's now handled in the Confirm screen

  SalonDesigner? selectedDesigner() {
    final selectedId = _state.selectedDesignerId;
    if (selectedId == null) {
      return null;
    }
    for (final designer in _state.designers) {
      if (designer.id == selectedId) {
        return designer;
      }
    }
    return null;
  }

  List<SalonService> selectedServices() {
    return _state.services
        .where((service) => _state.selectedServiceIds.contains(service.id))
        .toList();
  }

  Future<void> _loadInitialData({String? initialDesignerId}) async {
    _state = _state.copyWith(
      isLoading: true,
      loadError: null,
      submitError: null,
      selectedStartAt: null,
    );
    notifyListeners();

    try {
      final store = await _storeRepository.getStoreById(_state.storeId);
      if (store == null) {
        throw StateError('업장 정보를 찾을 수 없습니다.');
      }
      final designers = (await _salonRepository.getDesignersByStoreId(
        _state.storeId,
      )).where((designer) => designer.isActive).toList();
      final services = (await _salonRepository.getServicesByStoreId(
        _state.storeId,
      )).where((service) => service.isActive).toList();

      final selectedDesignerId = _pickInitialDesignerId(
        designers: designers,
        initialDesignerId: initialDesignerId,
      );
      _state = _state.copyWith(
        reservationSlotMinutes: store.reservationSlotMinutes,
        designers: designers,
        services: services,
        selectedDesignerId: selectedDesignerId,
        selectedServiceIds: const [],
        isLoading: false,
      );
      notifyListeners();

      if (selectedDesignerId != null) {
        await _loadSchedulesAndReservations(selectedDesignerId);
      } else {
        _state = _state.copyWith(schedules: const [], slots: const []);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(isLoading: false, loadError: e.toString());
      notifyListeners();
    }
  }

  Future<void> _selectDesigner(String designerId) async {
    if (_state.selectedDesignerId == designerId) {
      return;
    }
    _state = _state.copyWith(
      selectedDesignerId: designerId,
      selectedStartAt: null,
      submitError: null,
    );
    notifyListeners();
    await _loadSchedulesAndReservations(designerId);
  }

  Future<void> _selectDate(DateTime date) async {
    final selectedDate = _dateOnly(date);
    if (_state.selectedDate == selectedDate) {
      return;
    }
    _state = _state.copyWith(
      selectedDate: selectedDate,
      selectedStartAt: null,
      submitError: null,
    );
    notifyListeners();
    await _loadReservationsAndRecomputeSlots();
  }

  void _selectSlot(DateTime startAt) {
    final slot = _state.slots.where(
      (slot) => _sameUtcMinute(slot.startAt, startAt),
    );
    if (slot.isEmpty || !slot.first.isEnabled) {
      return;
    }
    _state = _state.copyWith(selectedStartAt: startAt, submitError: null);
    notifyListeners();
  }

  Future<void> _loadSchedulesAndReservations(String designerId) async {
    try {
      final schedules = await _salonRepository.getSchedulesByDesignerId(
        designerId,
      );
      _state = _state.copyWith(schedules: schedules);
      await _loadReservationsAndRecomputeSlots();
    } catch (e) {
      _state = _state.copyWith(loadError: e.toString(), slots: const []);
      notifyListeners();
    }
  }

  Future<void> _loadReservationsAndRecomputeSlots() async {
    final designerId = _state.selectedDesignerId;
    final date = _state.selectedDate;
    if (designerId == null || date == null) {
      _reservations = const [];
      _state = _state.copyWith(slots: const []);
      notifyListeners();
      return;
    }
    _reservations = await _salonRepository.getReservationsByDesignerAndDate(
      storeId: _state.storeId,
      designerId: designerId,
      date: date,
    );
    _recomputeSlots();
  }

  void _recomputeSlots() {
    final selectedDate = _state.selectedDate;
    final designerId = _state.selectedDesignerId;
    if (selectedDate == null || designerId == null) {
      _state = _state.copyWith(slots: const []);
      notifyListeners();
      return;
    }

    final y = selectedDate.year;
    final m = selectedDate.month;
    final d = selectedDate.day;
    final dayOfWeek = SalonBookingTime.seoulPostgresDayOfWeek(y, m, d);
    final schedules = _state.schedules.where(
      (schedule) => schedule.dayOfWeek == dayOfWeek && schedule.isWorking,
    );
    if (schedules.isEmpty) {
      _state = _state.copyWith(slots: const [], selectedStartAt: null);
      notifyListeners();
      return;
    }

    final schedule = schedules.first;
    final start = _seoulDateTimeForClock(y, m, d, schedule.startTime);
    final end = _seoulDateTimeForClock(y, m, d, schedule.endTime);
    if (!end.isAfter(start)) {
      _state = _state.copyWith(slots: const [], selectedStartAt: null);
      notifyListeners();
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final reservedStartAts = _reservations
        .where((reservation) => reservation.isConfirmed)
        .map((reservation) => reservation.startAt.toUtc())
        .toList();

    final slots = <SalonReservationSlot>[];
    DateTime cursor = start;
    while (cursor.isBefore(end)) {
      final isReserved = reservedStartAts.any(
        (reserved) => _sameUtcMinute(reserved, cursor),
      );
      slots.add(
        SalonReservationSlot(
          startAt: cursor,
          isReserved: isReserved,
          isPast: cursor.isBefore(nowUtc),
        ),
      );
      cursor = cursor.add(Duration(minutes: _state.reservationSlotMinutes));
    }

    final selectedStartAt = _state.selectedStartAt;
    final stillSelectable =
        selectedStartAt != null &&
        slots.any(
          (slot) =>
              _sameUtcMinute(slot.startAt, selectedStartAt) && slot.isEnabled,
        );

    _state = _state.copyWith(
      slots: slots,
      selectedStartAt: stillSelectable ? selectedStartAt : null,
    );
    notifyListeners();
  }

  String? _pickInitialDesignerId({
    required List<SalonDesigner> designers,
    required String? initialDesignerId,
  }) {
    if (designers.isEmpty) {
      return null;
    }
    if (initialDesignerId != null &&
        designers.any((designer) => designer.id == initialDesignerId)) {
      return initialDesignerId;
    }
    return designers.first.id;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _seoulDateTimeForClock(int year, int month, int day, String clock) {
    final parts = clock.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return SalonBookingTime.seoulWallToUtc(year, month, day, hour, minute);
  }

  bool _sameUtcMinute(DateTime a, DateTime b) {
    final ua = a.toUtc();
    final ub = b.toUtc();
    return ua.year == ub.year &&
        ua.month == ub.month &&
        ua.day == ub.day &&
        ua.hour == ub.hour &&
        ua.minute == ub.minute;
  }
}
