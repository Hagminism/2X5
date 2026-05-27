import 'dart:async';

import 'package:collection/collection.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_reservation_slot_default.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_schedule_exception.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/core/util/restaurant_booking_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_action.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_event.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_state.dart';
import 'package:flutter/material.dart';

class PartnerReservationSlotSettingsViewModel extends ChangeNotifier {
  PartnerReservationSlotSettingsViewModel({
    required StoreRepository storeRepository,
    required ReservationRepository reservationRepository,
  }) : _storeRepository = storeRepository,
       _reservationRepository = reservationRepository;

  final StoreRepository _storeRepository;
  final ReservationRepository _reservationRepository;

  PartnerReservationSlotSettingsState _state =
      PartnerReservationSlotSettingsState.initial();

  PartnerReservationSlotSettingsState get state => _state;

  Store? _store;
  List<RestaurantTimeSlot> _templateSlots = const [];

  final StreamController<PartnerReservationSlotSettingsEvent> _eventController =
      StreamController<PartnerReservationSlotSettingsEvent>.broadcast();

  Stream<PartnerReservationSlotSettingsEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize() async {
    _state = state.copyWith(isLoading: true, loadError: null);
    notifyListeners();

    try {
      final store = await _storeRepository.getMyStore();
      if (store == null) {
        throw StateError('등록된 업장이 없습니다.');
      }

      _store = store;
      _state = state.copyWith(
        storeId: store.id,
        reservationSlotMinutes: store.reservationSlotMinutes,
      );
      await _reloadForSelectedDate();
    } catch (error) {
      _state = state.copyWith(
        isLoading: false,
        loadError: error.toString(),
      );
      notifyListeners();
    }
  }

  void onAction(PartnerReservationSlotSettingsAction action) {
    switch (action) {
      case TapDatePicker():
        _eventController.add(OpenDatePicker(state.selectedDate));
        break;
      case SelectDate():
        unawaited(_selectDate(action.date));
        break;
      case ToggleSlotOpen():
        _updateSlot(action.time, (slot) {
          return slot.copyWith(isOpen: action.isOpen);
        });
        break;
      case TapIncreaseMaxGuestCount():
        _updateSlot(action.time, (slot) {
          final next = (slot.maxGuestCount + 1).clamp(1, 99);
          return slot.copyWith(maxGuestCount: next);
        });
        break;
      case TapDecreaseMaxGuestCount():
        _updateSlot(action.time, (slot) {
          final next = (slot.maxGuestCount - 1).clamp(1, 99);
          return slot.copyWith(maxGuestCount: next);
        });
        break;
      case ToggleExceptionClosed():
        _state = state.copyWith(isClosed: action.isClosed);
        notifyListeners();
        break;
      case ChangeExceptionOpenTime():
        _state = state.copyWith(exceptionOpenTime: action.openTime);
        notifyListeners();
        break;
      case ChangeExceptionCloseTime():
        _state = state.copyWith(exceptionCloseTime: action.closeTime);
        notifyListeners();
        break;
      case TapSave():
        unawaited(_save());
        break;
    }
  }

  Future<void> _selectDate(DateTime date) async {
    _state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );
    notifyListeners();
    await _reloadForSelectedDate();
  }

  Future<void> _reloadForSelectedDate() async {
    final store = _store;
    if (store == null) {
      return;
    }

    _state = state.copyWith(isLoading: true, loadError: null);
    notifyListeners();

    try {
      final selectedDate = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day,
      );

      final defaults =
          await _reservationRepository.getSlotDefaultsByStoreId(store.id);
      _templateSlots = RestaurantBookingSlot.buildSlotsForDate(
        store: store,
        targetDate: selectedDate,
        slotDefaults: defaults,
        scheduleException: null,
        reservations: const [],
      );

      final exception = await _reservationRepository.getScheduleException(
        storeId: store.id,
        date: selectedDate,
      );
      final reservations =
          await _reservationRepository.getReservationsByStoreAndDate(
        storeId: store.id,
        date: selectedDate,
      );
      final effectiveSlots = RestaurantBookingSlot.buildSlotsForDate(
        store: store,
        targetDate: selectedDate,
        slotDefaults: defaults,
        scheduleException: exception,
        reservations: reservations,
      );

      _state = state.copyWith(
        isLoading: false,
        isClosed: exception?.isClosed ?? false,
        exceptionOpenTime: exception?.openTime,
        exceptionCloseTime: exception?.closeTime,
        slots: effectiveSlots
            .map(
              (slot) => PartnerReservationSlot(
                time: slot.time,
                maxGuestCount: slot.maxGuestCount,
                reservedGuestCount: slot.reservedGuestCount,
                isOpen: slot.isOpen,
              ),
            )
            .toList(),
      );
      notifyListeners();
    } catch (error) {
      _state = state.copyWith(
        isLoading: false,
        loadError: error.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final store = _store;
    if (store == null || state.storeId.isEmpty) {
      return;
    }

    _state = state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();

    try {
      final defaults = state.slots
          .map(
            (slot) => StoreReservationSlotDefault(
              storeId: store.id,
              slotTime: slot.time,
              maxGuestCount: slot.maxGuestCount,
              isOpen: slot.isOpen,
            ),
          )
          .toList();

      await _reservationRepository.saveSlotDefaults(
        storeId: store.id,
        defaults: defaults,
      );

      final overrides = <StoreScheduleSlotOverride>[];
      for (final slot in state.slots) {
        final template = _templateSlots
            .where((item) => item.time == slot.time)
            .firstOrNull;
        if (template == null) {
          continue;
        }
        if (template.maxGuestCount != slot.maxGuestCount ||
            template.isOpen != slot.isOpen) {
          overrides.add(
            StoreScheduleSlotOverride(
              time: slot.time,
              maxGuestCount: slot.maxGuestCount,
              isOpen: slot.isOpen,
            ),
          );
        }
      }

      final hasException = state.isClosed ||
          (state.exceptionOpenTime?.isNotEmpty ?? false) ||
          (state.exceptionCloseTime?.isNotEmpty ?? false) ||
          overrides.isNotEmpty;

      if (hasException) {
        await _reservationRepository.upsertScheduleException(
          StoreScheduleException(
            storeId: store.id,
            exceptionDate: state.selectedDate,
            isClosed: state.isClosed,
            openTime: state.exceptionOpenTime,
            closeTime: state.exceptionCloseTime,
            slotOverrides: overrides,
          ),
        );
      } else {
        await _reservationRepository.deleteScheduleException(
          storeId: store.id,
          date: state.selectedDate,
        );
      }

      _state = state.copyWith(
        isSaving: false,
        saveMessage: '저장되었습니다.',
      );
      notifyListeners();
      _eventController.add(const ShowSnackBar('저장되었습니다.'));
      await _reloadForSelectedDate();
    } catch (error) {
      _state = state.copyWith(
        isSaving: false,
        saveMessage: error.toString(),
      );
      notifyListeners();
      _eventController.add(ShowSnackBar(error.toString()));
    }
  }

  void _updateSlot(
    String time,
    PartnerReservationSlot Function(PartnerReservationSlot slot) updater,
  ) {
    _state = state.copyWith(
      slots: state.slots
          .map((slot) => slot.time == time ? updater(slot) : slot)
          .toList(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
