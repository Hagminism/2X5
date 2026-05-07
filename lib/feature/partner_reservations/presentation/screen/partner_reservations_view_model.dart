import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/repository/reservation/reservation_repository.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_action.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_event.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_state.dart';
import 'package:flutter/foundation.dart';

class PartnerReservationsViewModel extends ChangeNotifier {
  final ReservationRepository _reservationRepository;

  PartnerReservationsViewModel({
    required ReservationRepository reservationRepository,
  }) : _reservationRepository = reservationRepository;

  PartnerReservationsState _state = const PartnerReservationsState();

  PartnerReservationsState get state => _state;

  final StreamController<PartnerReservationsEvent> _eventController =
      StreamController<PartnerReservationsEvent>.broadcast();

  Stream<PartnerReservationsEvent> get eventStream => _eventController.stream;

  void onAction(PartnerReservationsAction action) {
    switch (action) {
      case TapRetry():
        fetch();
        break;
      case TapDateFilter():
        _eventController.add(
          PartnerReservationsEvent.openDatePicker(state.selectedDate),
        );
        break;
      case SelectStatus():
        _state = state.copyWith(selectedStatus: action.status);
        notifyListeners();
        break;
      case SelectDate():
        _state = state.copyWith(selectedDate: action.date);
        notifyListeners();
        break;
      case TapChangeStatus():
        _changeStatus(
          reservationId: action.reservationId,
          status: action.status,
        );
        break;
    }
  }

  Future<void> fetch() async {
    // 중복 호출 방지
    if (state.isLoading) {
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final reservations = await _reservationRepository.fetchReservations();
      _state = state.copyWith(
        isLoading: false,
        reservations: reservations,
      );
      notifyListeners();
    } catch (_) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        const PartnerReservationsEvent.showMessage(
          '예약 목록을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  Future<void> _changeStatus({
    required String reservationId,
    required ReservationStatus status,
  }) async {
    // 중복 호출 방지
    if (state.isUpdating) {
      return;
    }

    _state = state.copyWith(
      isUpdating: true,
      updatingReservationId: reservationId,
    );
    notifyListeners();

    try {
      final updatedReservation = await _reservationRepository
          .updateReservationStatus(
            reservationId: reservationId,
            status: status,
          );
      final nextReservations = state.reservations
          .map(
            (item) => item.id == reservationId ? updatedReservation : item,
          )
          .toList();

      _state = state.copyWith(
        isUpdating: false,
        updatingReservationId: null,
        reservations: nextReservations,
      );
      notifyListeners();
      _eventController.add(
        PartnerReservationsEvent.showMessage(
          '예약 상태를 ${status.label}으로 변경했습니다.',
        ),
      );
    } catch (_) {
      _state = state.copyWith(
        isUpdating: false,
        updatingReservationId: null,
      );
      notifyListeners();
      _eventController.add(
        const PartnerReservationsEvent.showMessage(
          '예약 상태 변경에 실패했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
