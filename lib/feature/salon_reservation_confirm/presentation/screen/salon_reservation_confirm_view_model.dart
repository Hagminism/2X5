import 'dart:async';

import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/util/reservation_customer_request.dart';
import 'package:collection/collection.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_action.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_event.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_state.dart';
import 'package:capstone_2026/core/presentation/util/user_facing_error_message.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;
  final StoreRepository _storeRepository;

  SalonReservationConfirmViewModel({
    required SalonRepository salonRepository,
    required StoreRepository storeRepository,
  }) : _salonRepository = salonRepository,
       _storeRepository = storeRepository;

  SalonReservationConfirmState _state = const SalonReservationConfirmState();
  SalonReservationConfirmState get state => _state;

  final StreamController<SalonReservationConfirmEvent> _eventController =
      StreamController<SalonReservationConfirmEvent>.broadcast();

  Stream<SalonReservationConfirmEvent> get eventStream =>
      _eventController.stream;

  bool get canConfirm {
    return !state.isLoading &&
        !state.isSubmitting &&
        state.designer != null &&
        state.services.isNotEmpty;
  }

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

      final storeServices = await _salonRepository.getServicesByStoreId(
        storeId,
      );
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
        submitError: userFacingErrorMessage(
          e,
          fallback: '정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
    notifyListeners();
  }

  void onAction(SalonReservationConfirmAction action) {
    switch (action) {
      case TapConfirmBack():
        _eventController.add(const SalonReservationConfirmEvent.pop());
        break;
      case ChangeConfirmCustomerRequest():
        _state = _state.copyWith(
          customerRequest: action.value,
          submitError: null,
        );
        notifyListeners();
        break;
      case TapConfirmReservation():
        _requestSubmit();
        break;
      case ConfirmSubmitReservation():
        unawaited(_submit());
        break;
    }
  }

  void _requestSubmit() {
    if (!canConfirm) {
      return;
    }

    final designer = _state.designer;
    if (designer == null) {
      return;
    }

    _eventController.add(
      SalonReservationConfirmEvent.showConfirmDialog(
        designerName: designer.name,
        selectedDateTime: _state.selectedDateTime,
        serviceNames: _state.services.map((s) => s.name).join(', '),
        customerRequest: normalizeReservationCustomerRequest(
          _state.customerRequest,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!canConfirm || _state.isSubmitting) {
      return;
    }

    final designer = _state.designer;
    if (designer == null) {
      return;
    }

    _state = _state.copyWith(isSubmitting: true, submitError: null);
    notifyListeners();

    try {
      final customerRequest = normalizeReservationCustomerRequest(
        _state.customerRequest,
      );
      await _salonRepository.createReservation(
        storeId: _state.storeId,
        designerId: _state.designerId,
        serviceIds: _state.selectedServiceIds,
        startAt: DateTime.parse(_state.selectedDateTime).toUtc(),
        customerRequest: customerRequest,
      );

      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        SalonReservationConfirmEvent.showSuccessDialog(
          designerName: designer.name,
          selectedDateTime: _state.selectedDateTime,
          serviceNames: _state.services.map((s) => s.name).join(', '),
          customerRequest: customerRequest,
        ),
      );
    } catch (e) {
      final message = userFacingErrorMessage(
        e,
        fallback: '예약에 실패했습니다. 잠시 후 다시 시도해 주세요.',
      );
      _state = _state.copyWith(
        isSubmitting: false,
        submitError: message,
      );
      notifyListeners();
      _eventController.add(
        SalonReservationConfirmEvent.showSnackBar(message),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
