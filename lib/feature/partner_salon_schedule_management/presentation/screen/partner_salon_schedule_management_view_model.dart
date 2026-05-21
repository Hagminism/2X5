import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonScheduleManagementViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;

  PartnerSalonScheduleManagementViewModel({
    required SalonRepository salonRepository,
  }) : _salonRepository = salonRepository,
       _state = const PartnerSalonScheduleManagementState();

  PartnerSalonScheduleManagementState _state;

  PartnerSalonScheduleManagementState get state => _state;

  Future<void> initialize() async {
    await _load();
  }

  void onAction(PartnerSalonScheduleManagementAction action) {
    switch (action) {
      case PartnerSalonScheduleManagementTapRetry():
        unawaited(_load());
        break;
      case PartnerSalonScheduleManagementSelectDesigner(:final designerId):
        unawaited(selectDesigner(designerId));
        break;
      case PartnerSalonScheduleManagementTapBack():
      case PartnerSalonScheduleManagementTapEditSchedule():
        break;
    }
  }

  Future<void> saveSchedule(SalonDesignerSchedule schedule) async {
    _state = _state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();
    try {
      await _salonRepository.saveMyStoreSchedules([schedule]);
      await _loadSchedules(schedule.designerId);
      _state = _state.copyWith(
        isSaving: false,
        saveMessage: '근무표를 저장했습니다.',
      );
    } catch (e) {
      _state = _state.copyWith(isSaving: false, saveMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> selectDesigner(String designerId) async {
    _state = _state.copyWith(selectedDesignerId: designerId);
    notifyListeners();
    await _loadSchedules(designerId);
  }

  Future<void> _load() async {
    _state = _state.copyWith(
      isLoading: true,
      errorMessage: null,
      saveMessage: null,
    );
    notifyListeners();
    try {
      final designers = await _salonRepository.getMyStoreDesigners();
      final selectedDesignerId = designers.isNotEmpty
          ? designers.first.id
          : null;
      _state = _state.copyWith(
        isLoading: false,
        designers: designers,
        selectedDesignerId: selectedDesignerId,
      );
      notifyListeners();
      if (selectedDesignerId != null) {
        await _loadSchedules(selectedDesignerId);
      }
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<void> _loadSchedules(String designerId) async {
    final schedules = await _salonRepository.getSchedulesByDesignerId(
      designerId,
    );
    if (schedules.isEmpty) {
      final saved = await _salonRepository.saveMyStoreSchedules(
        _defaultSchedules(designerId),
      );
      _state = _state.copyWith(schedules: saved);
      notifyListeners();
      return;
    }
    _state = _state.copyWith(schedules: schedules);
    notifyListeners();
  }

  List<SalonDesignerSchedule> _defaultSchedules(String designerId) {
    return List.generate(
      7,
      (day) => SalonDesignerSchedule(
        id: '',
        designerId: designerId,
        dayOfWeek: day,
        isWorking: day != 0,
      ),
    );
  }
}
