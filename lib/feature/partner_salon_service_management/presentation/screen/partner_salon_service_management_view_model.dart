import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonServiceManagementViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;

  PartnerSalonServiceManagementViewModel({
    required SalonRepository salonRepository,
  }) : _salonRepository = salonRepository,
       _state = const PartnerSalonServiceManagementState();

  PartnerSalonServiceManagementState _state;

  PartnerSalonServiceManagementState get state => _state;

  Future<void> initialize() async {
    await _load();
  }

  void onAction(PartnerSalonServiceManagementAction action) {
    switch (action) {
      case PartnerSalonServiceManagementTapRetry():
        unawaited(_load());
        break;
      case PartnerSalonServiceManagementTapBack():
      case PartnerSalonServiceManagementTapAddService():
      case PartnerSalonServiceManagementTapEditService():
      case PartnerSalonServiceManagementTapToggleService():
        break;
    }
  }

  Future<void> saveService({
    required String id,
    required String name,
    required String description,
    required int durationMinutes,
    required int price,
    required bool isActive,
  }) async {
    _state = _state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();
    try {
      final existing = _findService(id);
      await _salonRepository.saveMyStoreServices([
        SalonService(
          id: id,
          storeId: _state.settings.storeId,
          name: name,
          description: description,
          durationMinutes: durationMinutes,
          price: price,
          isActive: isActive,
          sortOrder: existing?.sortOrder ?? _state.services.length,
        ),
      ]);
      await _loadServices();
      _state = _state.copyWith(
        isSaving: false,
        saveMessage: '시술 정보를 저장했습니다.',
      );
    } catch (e) {
      _state = _state.copyWith(isSaving: false, saveMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> _load() async {
    _state = _state.copyWith(
      isLoading: true,
      errorMessage: null,
      saveMessage: null,
    );
    notifyListeners();
    try {
      final settings = await _salonRepository.getMyStoreSettings();
      final services = await _salonRepository.getMyStoreServices();
      _state = _state.copyWith(
        isLoading: false,
        settings: settings,
        services: services,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<void> _loadServices() async {
    final services = await _salonRepository.getMyStoreServices();
    _state = _state.copyWith(services: services);
  }

  SalonService? _findService(String id) {
    for (final service in _state.services) {
      if (service.id == id) {
        return service;
      }
    }
    return null;
  }
}
