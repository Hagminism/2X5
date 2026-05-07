import 'dart:async';

import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_event.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStoreMenuViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final Set<String> _pendingDeleteImageUrls = <String>{};

  PartnerStoreMenuViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  PartnerStoreMenuState _state = const PartnerStoreMenuState();
  PartnerStoreMenuState get state => _state;

  final StreamController<PartnerStoreMenuEvent> _eventController =
      StreamController<PartnerStoreMenuEvent>.broadcast();
  Stream<PartnerStoreMenuEvent> get eventStream => _eventController.stream;

  void onAction(PartnerStoreMenuAction action) {
    switch (action) {
      case AddMenu():
        _addMenu();
        break;
      case RemoveMenu():
        _removeMenu(action.index);
        break;
      case ChangeMenuName():
        _changeMenuName(action.index, action.value);
        break;
      case ChangeMenuPrice():
        _changeMenuPrice(action.index, action.value);
        break;
      case ChangeMenuDescription():
        _changeMenuDescription(action.index, action.value);
        break;
      case TapPickMenuImage():
        break;
      case RemoveMenuImage():
        _removeMenuImage(action.index);
        break;
      case ToggleMenuAvailable():
        _toggleMenuAvailable(action.index, action.value);
        break;
      case TapSave():
        save();
        break;
    }
  }

  Future<void> initialize() async {
    if (_state.isLoading) {
      return;
    }
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final menus = await _storeRepository.getMyStoreMenus();
      final normalized = _withReindexedMenus(menus);
      _state = _state.copyWith(
        menus: normalized,
        localImagePaths: List<String?>.filled(normalized.length, null),
      );
    } catch (_) {
      _eventController.add(
        const PartnerStoreMenuEvent.showMessage('메뉴 목록을 불러오지 못했습니다.'),
      );
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  void _addMenu() {
    _state = _state.copyWith(
      menus: [
        ..._state.menus,
        StoreMenu(name: '', price: 0, sortOrder: _state.menus.length),
      ],
      localImagePaths: [..._state.localImagePaths, null],
    );
    notifyListeners();
  }

  void _removeMenu(int index) {
    if (index < 0 || index >= _state.menus.length) {
      return;
    }
    final next = List<StoreMenu>.from(_state.menus)..removeAt(index);
    _collectDeleteTarget(_state.menus[index].imageUrl);
    final nextLocalPaths = List<String?>.from(_state.localImagePaths);
    if (index < nextLocalPaths.length) {
      nextLocalPaths.removeAt(index);
    }
    _state = _state.copyWith(
      menus: _withReindexedMenus(next),
      localImagePaths: nextLocalPaths,
    );
    notifyListeners();
  }

  void _changeMenuName(int index, String value) {
    _updateMenuAt(index, (menu) => menu.copyWith(name: value));
  }

  void _changeMenuPrice(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    _updateMenuAt(
      index,
      (menu) => menu.copyWith(price: int.tryParse(digitsOnly.trim()) ?? 0),
    );
  }

  void _changeMenuDescription(int index, String value) {
    _updateMenuAt(index, (menu) => menu.copyWith(description: value));
  }

  Future<void> updateMenuImageFromFile({
    required int index,
    required String filePath,
  }) async {
    if (index < 0 || index >= _state.menus.length) {
      return;
    }
    _collectDeleteTarget(_state.menus[index].imageUrl);
    final nextLocalPaths = List<String?>.from(_state.localImagePaths);
    while (nextLocalPaths.length < _state.menus.length) {
      nextLocalPaths.add(null);
    }
    nextLocalPaths[index] = filePath;
    _state = _state.copyWith(localImagePaths: nextLocalPaths);
    notifyListeners();
  }

  void _toggleMenuAvailable(int index, bool value) {
    _updateMenuAt(index, (menu) => menu.copyWith(isAvailable: value));
  }

  void _removeMenuImage(int index) {
    if (index < 0 || index >= _state.menus.length) {
      return;
    }
    _collectDeleteTarget(_state.menus[index].imageUrl);
    _updateMenuAt(index, (menu) => menu.copyWith(imageUrl: ''));
    final nextLocalPaths = List<String?>.from(_state.localImagePaths);
    if (index < nextLocalPaths.length) {
      nextLocalPaths[index] = null;
      _state = _state.copyWith(localImagePaths: nextLocalPaths);
      notifyListeners();
    }
  }

  Future<void> save() async {
    _state = _state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final nextMenus = _withReindexedMenus(_state.menus);
      final nextLocalPaths = List<String?>.from(_state.localImagePaths);

      for (var i = 0; i < nextMenus.length; i++) {
        final localPath = i < nextLocalPaths.length ? nextLocalPaths[i] : null;
        if (localPath == null || localPath.isEmpty) {
          continue;
        }
        final uploadedUrl = await _storeRepository.uploadMyStoreMenuImageFile(
          localPath,
        );
        nextMenus[i] = nextMenus[i].copyWith(imageUrl: uploadedUrl);
      }

      await _storeRepository.syncMyStoreMenus(nextMenus);
      final protectedUrls = nextMenus
          .map((menu) => menu.imageUrl.trim())
          .where((url) => url.isNotEmpty)
          .toSet();
      final deleteTargets = _pendingDeleteImageUrls
          .where((url) => !protectedUrls.contains(url))
          .toList();
      for (final imageUrl in deleteTargets) {
        await _storeRepository.deleteMyStoreMenuImageByUrl(imageUrl);
      }
      _state = _state.copyWith(
        menus: nextMenus,
        localImagePaths: List<String?>.filled(nextMenus.length, null),
      );
      _pendingDeleteImageUrls.clear();
      _eventController.add(
        const PartnerStoreMenuEvent.showMessage('메뉴가 저장되었습니다.'),
      );
      _eventController.add(const PartnerStoreMenuEvent.pop());
    } catch (e) {
      _eventController.add(PartnerStoreMenuEvent.showMessage(e.toString()));
    } finally {
      _state = _state.copyWith(isSaving: false);
      notifyListeners();
    }
  }

  void _updateMenuAt(
    int index,
    StoreMenu Function(StoreMenu current) update,
  ) {
    if (index < 0 || index >= _state.menus.length) {
      return;
    }
    final next = List<StoreMenu>.from(_state.menus);
    next[index] = update(next[index]);
    _state = _state.copyWith(menus: _withReindexedMenus(next));
    notifyListeners();
  }

  List<StoreMenu> _withReindexedMenus(List<StoreMenu> menus) {
    return List<StoreMenu>.generate(
      menus.length,
      (index) => menus[index].copyWith(sortOrder: index),
    );
  }

  void _collectDeleteTarget(String imageUrl) {
    final normalized = imageUrl.trim();
    if (normalized.isEmpty) {
      return;
    }
    _pendingDeleteImageUrls.add(normalized);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
