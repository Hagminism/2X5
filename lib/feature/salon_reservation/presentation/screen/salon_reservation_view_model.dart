import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_reservation.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_state.dart';
import 'package:flutter/foundation.dart';

class SalonReservationViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;

  SalonReservationViewModel({
    required SalonRepository salonRepository,
  }) : _salonRepository = salonRepository,
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
      (slot) => _sameMinute(slot.startAt, selectedStartAt) && slot.isEnabled,
    );
    return !_state.isLoading &&
        !_state.isSubmitting &&
        _state.loadError == null &&
        _state.selectedDesignerId != null &&
        _state.selectedServiceId != null &&
        enabledSlot;
  }

  Future<void> initialize(String storeId) async {
    _state = SalonReservationState(
      storeId: storeId,
      selectedDate: _dateOnly(DateTime.now()),
    );
    notifyListeners();
    await _loadInitialData();
  }

  void onAction(SalonReservationAction action) {
    switch (action) {
      case SalonReservationTapRetry():
        unawaited(_loadInitialData());
        break;
      case SalonReservationSelectDesigner(:final designerId):
        unawaited(_selectDesigner(designerId));
        break;
      case SalonReservationSelectService(:final serviceId):
        _state = _state.copyWith(
          selectedServiceId: serviceId,
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

  Future<bool> submitReservation() async {
    if (!canSubmit) {
      return false;
    }

    _state = _state.copyWith(isSubmitting: true, submitError: null);
    notifyListeners();

    try {
      await _salonRepository.createReservation(
        storeId: _state.storeId,
        designerId: _state.selectedDesignerId!,
        serviceId: _state.selectedServiceId!,
        startAt: _state.selectedStartAt!,
      );
      await _loadReservationsAndRecomputeSlots();
      _state = _state.copyWith(selectedStartAt: null);
      return true;
    } catch (e) {
      _state = _state.copyWith(submitError: e.toString());
      return false;
    } finally {
      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
    }
  }

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

  SalonService? selectedService() {
    final selectedId = _state.selectedServiceId;
    if (selectedId == null) {
      return null;
    }
    for (final service in _state.services) {
      if (service.id == selectedId) {
        return service;
      }
    }
    return null;
  }

  Future<void> _loadInitialData() async {
    _state = _state.copyWith(
      isLoading: true,
      loadError: null,
      submitError: null,
      selectedStartAt: null,
    );
    notifyListeners();

    try {
      final settings = await _salonRepository.getSettingsByStoreId(
        _state.storeId,
      );
      final designers = (await _salonRepository.getDesignersByStoreId(
        _state.storeId,
      )).where((designer) => designer.isActive).toList();
      final services = (await _salonRepository.getServicesByStoreId(
        _state.storeId,
      )).where((service) => service.isActive).toList();

      final selectedDesignerId = designers.isNotEmpty
          ? designers.first.id
          : null;
      final selectedServiceId = services.isNotEmpty ? services.first.id : null;

      _state = _state.copyWith(
        settings: settings,
        designers: designers,
        services: services,
        selectedDesignerId: selectedDesignerId,
        selectedServiceId: selectedServiceId,
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
      (slot) => _sameMinute(slot.startAt, startAt),
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

    final dayOfWeek = selectedDate.weekday % 7;
    final schedules = _state.schedules.where(
      (schedule) => schedule.dayOfWeek == dayOfWeek && schedule.isWorking,
    );
    if (schedules.isEmpty) {
      _state = _state.copyWith(slots: const [], selectedStartAt: null);
      notifyListeners();
      return;
    }

    final schedule = schedules.first;
    final start = _dateTimeForClock(selectedDate, schedule.startTime);
    final end = _dateTimeForClock(selectedDate, schedule.endTime);
    if (!end.isAfter(start)) {
      _state = _state.copyWith(slots: const [], selectedStartAt: null);
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final reservedStartAts = _reservations
        .where((reservation) => reservation.isConfirmed)
        .map((reservation) => reservation.startAt.toLocal())
        .toList();

    final slots = <SalonReservationSlot>[];
    DateTime cursor = start;
    while (cursor.isBefore(end)) {
      final isReserved = reservedStartAts.any(
        (reserved) => _sameMinute(reserved, cursor),
      );
      slots.add(
        SalonReservationSlot(
          startAt: cursor,
          isReserved: isReserved,
          isPast: cursor.isBefore(now),
        ),
      );
      cursor = cursor.add(Duration(minutes: _state.settings.slotMinutes));
    }

    final selectedStartAt = _state.selectedStartAt;
    final stillSelectable =
        selectedStartAt != null &&
        slots.any(
          (slot) =>
              _sameMinute(slot.startAt, selectedStartAt) && slot.isEnabled,
        );

    _state = _state.copyWith(
      slots: slots,
      selectedStartAt: stillSelectable ? selectedStartAt : null,
    );
    notifyListeners();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _dateTimeForClock(DateTime date, String clock) {
    final parts = clock.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool _sameMinute(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day &&
        localA.hour == localB.hour &&
        localA.minute == localB.minute;
  }
}
