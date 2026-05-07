import 'dart:async';

import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_slot_interval.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_action.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_event.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_state.dart';
import 'package:flutter/material.dart';

class PartnerReservationSlotSettingsViewModel extends ChangeNotifier {
  PartnerReservationSlotSettingsState _state =
      PartnerReservationSlotSettingsState.initial();

  PartnerReservationSlotSettingsState get state => _state;

  final StreamController<PartnerReservationSlotSettingsEvent> _eventController =
      StreamController<PartnerReservationSlotSettingsEvent>.broadcast();

  Stream<PartnerReservationSlotSettingsEvent> get eventStream =>
      _eventController.stream;

  void initialize() {
    _state = state.copyWith(
      slots: _generateMockSlots(state.slotInterval),
    );
    notifyListeners();
  }

  void onAction(PartnerReservationSlotSettingsAction action) {
    switch (action) {
      case TapDatePicker():
        _eventController.add(OpenDatePicker(state.selectedDate));
        break;
      case SelectDate():
        _state = state.copyWith(
          selectedDate: action.date,
          slots: _generateMockSlots(state.slotInterval),
        );
        notifyListeners();
        break;
      case ChangeSlotInterval():
        _state = state.copyWith(
          slotInterval: action.interval,
          slots: _generateMockSlots(action.interval),
        );
        notifyListeners();
        break;
      case ToggleSlotOpen():
        _updateSlot(action.time, (current) {
          return current.copyWith(isOpen: action.isOpen);
        });
        break;
      case TapIncreaseMaxTeamCount():
        _updateSlot(action.time, (current) {
          final next = (current.maxTeamCount + 1).clamp(1, 99);
          return current.copyWith(maxTeamCount: next);
        });
        break;
      case TapDecreaseMaxTeamCount():
        _updateSlot(action.time, (current) {
          final next = (current.maxTeamCount - 1).clamp(1, 99);
          return current.copyWith(maxTeamCount: next);
        });
        break;
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

  List<PartnerReservationSlot> _generateMockSlots(
    ReservationSlotInterval interval,
  ) {
    final openingHour = 10;
    final closingHour = 20;
    final slots = <PartnerReservationSlot>[];
    final minuteStep = interval.minutes;
    var index = 0;

    for (var hour = openingHour; hour < closingHour; hour++) {
      for (var minute = 0; minute < 60; minute += minuteStep) {
        if (hour == closingHour - 1 && minute >= 30 && minuteStep == 60) {
          continue;
        }
        final time =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final maxTeam = 4 + (index % 3);
        final reservedTeam = (index * 2) % (maxTeam + 1);
        slots.add(
          PartnerReservationSlot(
            time: time,
            maxTeamCount: maxTeam,
            reservedTeamCount: reservedTeam,
            isOpen: (index % 7) != 0,
          ),
        );
        index++;
      }
    }

    return slots;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
