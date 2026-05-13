import 'dart:async';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_event.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonDesignerManagementViewModel extends ChangeNotifier {
  final SalonRepository _salonRepository;
  final StoreRepository _storeRepository;
  final Set<String> _pendingDeleteDesignerImageUrls = <String>{};

  PartnerSalonDesignerManagementViewModel({
    required SalonRepository salonRepository,
    required StoreRepository storeRepository,
  }) : _salonRepository = salonRepository,
       _storeRepository = storeRepository,
       _state = const PartnerSalonDesignerManagementState();

  PartnerSalonDesignerManagementState _state;

  PartnerSalonDesignerManagementState get state => _state;

  final StreamController<PartnerSalonDesignerManagementEvent> _eventController =
      StreamController<PartnerSalonDesignerManagementEvent>.broadcast();
  Stream<PartnerSalonDesignerManagementEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize() async {
    await _load();
  }

  void onAction(PartnerSalonDesignerManagementAction action) {
    switch (action) {
      case PartnerSalonDesignerManagementTapRetry():
        unawaited(_load());
        break;
      case PartnerSalonDesignerManagementTapAddDesigner():
        _addDesigner();
        break;
      case PartnerSalonDesignerManagementTapRemoveDesigner(:final index):
        _removeDesigner(index);
        break;
      case PartnerSalonDesignerManagementChangeDesignerName(
        :final index,
        :final value,
      ):
        _updateDesignerAt(index, (designer) => designer.copyWith(name: value));
        break;
      case PartnerSalonDesignerManagementChangeDesignerIntroduction(
        :final index,
        :final value,
      ):
        _updateDesignerAt(
          index,
          (designer) => designer.copyWith(introduction: value),
        );
        break;
      case PartnerSalonDesignerManagementRemoveDesignerImage(:final index):
        _removeDesignerImage(index);
        break;
      case PartnerSalonDesignerManagementToggleDesignerActive(
        :final index,
        :final value,
      ):
        _updateDesignerAt(
          index,
          (designer) => designer.copyWith(isActive: value),
        );
        break;
      case PartnerSalonDesignerManagementTapSaveDesigners():
        unawaited(saveDesigners());
        break;
      case PartnerSalonDesignerManagementTapPickDesignerImage(:final index):
        _eventController.add(
          PartnerSalonDesignerManagementEvent.openGallery(index),
        );
        break;
      case PartnerSalonDesignerManagementTapBack():
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
            .uploadMySalonDesignerImageFile(localPath);
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
        isSaving: false,
        saveMessage: null,
      );
      _eventController.add(
        const PartnerSalonDesignerManagementEvent.popWithMessage(
          '디자이너 정보를 저장했습니다.',
        ),
      );
    } catch (e) {
      _state = _state.copyWith(isSaving: false);
      _eventController.add(
        PartnerSalonDesignerManagementEvent.showMessage(e.toString()),
      );
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
      final designers = await _salonRepository.getMyStoreDesigners();
      _state = _state.copyWith(
        isLoading: false,
        designers: designers,
        localDesignerImagePaths: List<String?>.filled(designers.length, null),
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      _eventController.add(
        PartnerSalonDesignerManagementEvent.showMessage(e.toString()),
      );
    }
    notifyListeners();
  }

  void _addDesigner() {
    _state = _state.copyWith(
      designers: [
        ..._state.designers,
        SalonDesigner(
          id: '',
          storeId: '',
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
