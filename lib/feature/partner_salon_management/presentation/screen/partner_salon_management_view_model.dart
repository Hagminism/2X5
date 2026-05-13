import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonManagementViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;
  final StoreRepository _storeRepository;
  final Set<String> _pendingDeleteDesignerImageUrls = <String>{};

  PartnerSalonManagementViewModel({
    required SalonRepository salonRepository,
    required StoreRepository storeRepository,
  }) : _salonRepository = salonRepository,
       _storeRepository = storeRepository,
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
      case PartnerSalonManagementSelectDesigner(:final designerId):
        unawaited(selectDesigner(designerId));
        break;
      case PartnerSalonManagementTapAddDesigner():
        _addDesigner();
        break;
      case PartnerSalonManagementTapRemoveDesigner(:final index):
        _removeDesigner(index);
        break;
      case PartnerSalonManagementChangeDesignerName(
        :final index,
        :final value,
      ):
        _updateDesignerAt(index, (designer) => designer.copyWith(name: value));
        break;
      case PartnerSalonManagementChangeDesignerIntroduction(
        :final index,
        :final value,
      ):
        _updateDesignerAt(
          index,
          (designer) => designer.copyWith(introduction: value),
        );
        break;
      case PartnerSalonManagementRemoveDesignerImage(:final index):
        _removeDesignerImage(index);
        break;
      case PartnerSalonManagementToggleDesignerActive(
        :final index,
        :final value,
      ):
        _updateDesignerAt(
          index,
          (designer) => designer.copyWith(isActive: value),
        );
        break;
      case PartnerSalonManagementTapSaveDesigners():
        unawaited(saveDesigners());
        break;
      case PartnerSalonManagementTapBack():
      case PartnerSalonManagementOpenDesignerManagement():
      case PartnerSalonManagementOpenServiceManagement():
      case PartnerSalonManagementTapPickDesignerImage():
      case PartnerSalonManagementTapAddService():
      case PartnerSalonManagementTapEditService():
      case PartnerSalonManagementTapToggleService():
      case PartnerSalonManagementTapEditSchedule():
        break;
    }
  }

  Future<void> updateDesignerImageFromFile({
    required int index,
    required String filePath,
  }) async {
    if (index < 0 || index >= _state.designers.length) {
      return;
    }
    _collectDeleteDesignerImageTarget(_state.designers[index].imageUrl);
    final nextLocalPaths = List<String?>.from(_state.localDesignerImagePaths);
    while (nextLocalPaths.length < _state.designers.length) {
      nextLocalPaths.add(null);
    }
    nextLocalPaths[index] = filePath;
    _state = _state.copyWith(localDesignerImagePaths: nextLocalPaths);
    notifyListeners();
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

  Future<void> saveDesigner({
    required String id,
    required String name,
    required String introduction,
    required String imageUrl,
    required bool isActive,
  }) async {
    _state = _state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();
    try {
      final existing = _findDesigner(id);
      final saved = await _salonRepository.saveMyStoreDesigners([
        SalonDesigner(
          id: id,
          storeId: _state.settings.storeId,
          name: name,
          introduction: introduction,
          imageUrl: imageUrl,
          isActive: isActive,
          sortOrder: existing?.sortOrder ?? _state.designers.length,
        ),
      ]);
      await _loadDesigners();
      final selectedId = saved.isNotEmpty ? saved.first.id : id;
      if (selectedId.isNotEmpty) {
        await selectDesigner(selectedId);
      }
      _state = _state.copyWith(
        isSaving: false,
        saveMessage: '디자이너 정보를 저장했습니다.',
      );
    } catch (e) {
      _state = _state.copyWith(isSaving: false, saveMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> saveDesigners() async {
    _state = _state.copyWith(isSaving: true, saveMessage: null);
    notifyListeners();
    try {
      final nextDesigners = _withReindexedDesigners(_state.designers);
      final nextLocalPaths = List<String?>.from(_state.localDesignerImagePaths);

      for (var i = 0; i < nextDesigners.length; i++) {
        final localPath = i < nextLocalPaths.length ? nextLocalPaths[i] : null;
        if (localPath == null || localPath.isEmpty) {
          continue;
        }
        final uploadedUrl = await _storeRepository
            .uploadMySalonDesignerImageFile(
              localPath,
            );
        nextDesigners[i] = nextDesigners[i].copyWith(imageUrl: uploadedUrl);
      }

      final validDesigners = nextDesigners
          .where((designer) => designer.name.trim().isNotEmpty)
          .toList();
      final saved = await _salonRepository.saveMyStoreDesigners(validDesigners);
      final protectedUrls = saved
          .map((designer) => designer.imageUrl.trim())
          .where((url) => url.isNotEmpty)
          .toSet();
      final deleteTargets = _pendingDeleteDesignerImageUrls
          .where((url) => !protectedUrls.contains(url))
          .toList();
      for (final imageUrl in deleteTargets) {
        await _storeRepository.deleteMySalonDesignerImageByUrl(imageUrl);
      }
      _pendingDeleteDesignerImageUrls.clear();
      _state = _state.copyWith(
        designers: saved,
        localDesignerImagePaths: List<String?>.filled(saved.length, null),
        selectedDesignerId: saved.isNotEmpty ? saved.first.id : null,
        isSaving: false,
        saveMessage: '디자이너 정보를 저장했습니다.',
      );
      notifyListeners();
      if (saved.isNotEmpty) {
        await _loadSchedules(saved.first.id);
      }
    } catch (e) {
      _state = _state.copyWith(isSaving: false, saveMessage: e.toString());
      notifyListeners();
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
      final settings = await _salonRepository.getMyStoreSettings();
      final designers = await _salonRepository.getMyStoreDesigners();
      final services = await _salonRepository.getMyStoreServices();
      final selectedDesignerId = designers.isNotEmpty
          ? designers.first.id
          : null;
      _state = _state.copyWith(
        isLoading: false,
        settings: settings,
        designers: designers,
        localDesignerImagePaths: List<String?>.filled(designers.length, null),
        services: services,
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

  Future<void> _loadDesigners() async {
    final designers = await _salonRepository.getMyStoreDesigners();
    _state = _state.copyWith(
      designers: designers,
      localDesignerImagePaths: List<String?>.filled(designers.length, null),
    );
  }

  Future<void> _loadServices() async {
    final services = await _salonRepository.getMyStoreServices();
    _state = _state.copyWith(services: services);
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

  void _addDesigner() {
    _state = _state.copyWith(
      designers: [
        ..._state.designers,
        SalonDesigner(
          id: '',
          storeId: _state.settings.storeId,
          name: '',
          sortOrder: _state.designers.length,
        ),
      ],
      localDesignerImagePaths: [..._state.localDesignerImagePaths, null],
      saveMessage: null,
    );
    notifyListeners();
  }

  void _removeDesigner(int index) {
    if (index < 0 || index >= _state.designers.length) {
      return;
    }
    _collectDeleteDesignerImageTarget(_state.designers[index].imageUrl);
    final nextDesigners = List<SalonDesigner>.from(_state.designers)
      ..removeAt(index);
    final nextLocalPaths = List<String?>.from(_state.localDesignerImagePaths);
    if (index < nextLocalPaths.length) {
      nextLocalPaths.removeAt(index);
    }
    _state = _state.copyWith(
      designers: _withReindexedDesigners(nextDesigners),
      localDesignerImagePaths: nextLocalPaths,
      saveMessage: null,
    );
    notifyListeners();
  }

  void _removeDesignerImage(int index) {
    if (index < 0 || index >= _state.designers.length) {
      return;
    }
    _collectDeleteDesignerImageTarget(_state.designers[index].imageUrl);
    _updateDesignerAt(index, (designer) => designer.copyWith(imageUrl: ''));
    final nextLocalPaths = List<String?>.from(_state.localDesignerImagePaths);
    if (index < nextLocalPaths.length) {
      nextLocalPaths[index] = null;
      _state = _state.copyWith(localDesignerImagePaths: nextLocalPaths);
      notifyListeners();
    }
  }

  void _updateDesignerAt(
    int index,
    SalonDesigner Function(SalonDesigner current) update,
  ) {
    if (index < 0 || index >= _state.designers.length) {
      return;
    }
    final next = List<SalonDesigner>.from(_state.designers);
    next[index] = update(next[index]);
    _state = _state.copyWith(
      designers: _withReindexedDesigners(next),
      saveMessage: null,
    );
    notifyListeners();
  }

  List<SalonDesigner> _withReindexedDesigners(List<SalonDesigner> designers) {
    return List<SalonDesigner>.generate(
      designers.length,
      (index) => designers[index].copyWith(sortOrder: index),
    );
  }

  void _collectDeleteDesignerImageTarget(String imageUrl) {
    final normalized = imageUrl.trim();
    if (normalized.isEmpty) {
      return;
    }
    _pendingDeleteDesignerImageUrls.add(normalized);
  }

  SalonDesigner? _findDesigner(String id) {
    for (final designer in _state.designers) {
      if (designer.id == id) {
        return designer;
      }
    }
    return null;
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
