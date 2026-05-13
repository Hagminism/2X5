import 'dart:async';

import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonManagementViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;

  PartnerSalonManagementViewModel({
    required SalonRepository salonRepository,
  }) : _salonRepository = salonRepository,
       _state = const PartnerSalonManagementState();

  PartnerSalonManagementState _state;

  PartnerSalonManagementState get state => _state;

  Future<void> initialize() async {
    await _load();
  }

  void onAction(PartnerSalonManagementAction action) {
    switch (action) {
      case PartnerSalonManagementTapRetry():
        unawaited(_load());
        break;
      case PartnerSalonManagementSelectSlotMinutes(:final minutes):
        unawaited(saveSlotMinutes(minutes));
        break;
      case PartnerSalonManagementTapBack():
      case PartnerSalonManagementOpenDesignerManagement():
      case PartnerSalonManagementOpenServiceManagement():
        break;
    }
  }

  Future<void> saveSlotMinutes(int minutes) async {
    _state = _state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();
    try {
      final saved = await _salonRepository.saveMyStoreSettings(
        _state.settings.copyWith(slotMinutes: minutes),
      );
      _state = _state.copyWith(
        settings: saved,
        isSaving: false,
        saveMessage: '슬롯 설정을 저장했습니다.',
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
      _state = _state.copyWith(
        isLoading: false,
        settings: settings,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }
}
