import 'dart:async';

import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:collection/collection.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_action.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_event.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_state.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;
  final StoreRepository _storeRepository;

  SalonReservationConfirmViewModel({
    required SalonRepository salonRepository,
    required StoreRepository storeRepository,
  })  : _salonRepository = salonRepository,
        _storeRepository = storeRepository;

  SalonReservationConfirmState _state = const SalonReservationConfirmState();
  SalonReservationConfirmState get state => _state;

  final StreamController<SalonReservationConfirmEvent> _eventController =
      StreamController<SalonReservationConfirmEvent>.broadcast();

  Stream<SalonReservationConfirmEvent> get eventStream => _eventController.stream;

  Future<void> initialize({
    required String storeId,
    required String designerId,
    required List<String> selectedServices,
    required String selectedDateTime,
  }) async {
    _state = _state.copyWith(
      isLoading: true,
      storeId: storeId,
      designerId: designerId,
      selectedServiceIds: selectedServices,
      selectedDateTime: selectedDateTime,
    );
    notifyListeners();

    try {
      final store = await _storeRepository.getStoreById(storeId);
      final designers = await _salonRepository.getDesignersByStoreId(storeId);
      final designer = designers.firstWhereOrNull((d) => d.id == designerId);

      if (designer == null) {
        _state = _state.copyWith(
          isLoading: false,
          store: store,
          submitError: '선택한 디자이너 정보를 찾을 수 없습니다.',
        );
        notifyListeners();
        return;
      }

      final storeServices = await _salonRepository.getServicesByStoreId(storeId);
      final services = storeServices
          .where((s) => selectedServices.contains(s.id))
          .toList();

      _state = _state.copyWith(
        isLoading: false,
        store: store,
        designer: designer,
        services: services,
        submitError: null,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        submitError: '정보를 불러오는데 실패했습니다: $e',
      );
    }
    notifyListeners();
  }

  Future<void> onAction(SalonReservationConfirmAction action) async {
    switch (action) {
      case TapConfirmBack():
        _eventController.add(const SalonReservationConfirmEvent.pop());
        break;
      case TapConfirmReservation():
        if (_state.isSubmitting) return;

        _state = _state.copyWith(isSubmitting: true, submitError: null);
        notifyListeners();

        try {
          await _salonRepository.createReservation(
            storeId: _state.storeId,
            designerId: _state.designerId,
            serviceIds: _state.selectedServiceIds,
            startAt: DateTime.parse(_state.selectedDateTime).toUtc(),
          );
          
          _eventController.add(const SalonReservationConfirmEvent.showSnackBar('예약이 확정되었습니다.'));
          _eventController.add(const SalonReservationConfirmEvent.navigateHome());
        } catch (e) {
          _state = _state.copyWith(submitError: e.toString());
          _eventController.add(SalonReservationConfirmEvent.showSnackBar('예약에 실패했습니다: $e'));
        } finally {
          _state = _state.copyWith(isSubmitting: false);
          notifyListeners();
        }
        break;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
