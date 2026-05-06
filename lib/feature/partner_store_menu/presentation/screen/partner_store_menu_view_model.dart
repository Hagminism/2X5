import 'dart:async';

import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_event.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStoreMenuViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

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
      case ChangeMenuImageUrl():
        _changeMenuImageUrl(action.index, action.value);
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
      _state = _state.copyWith(menus: _withReindexedMenus(menus));
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
    );
    notifyListeners();
  }

  void _removeMenu(int index) {
    if (index < 0 || index >= _state.menus.length) {
      return;
    }
    final next = List<StoreMenu>.from(_state.menus)..removeAt(index);
    _state = _state.copyWith(menus: _withReindexedMenus(next));
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

  void _changeMenuImageUrl(int index, String value) {
    _updateMenuAt(index, (menu) => menu.copyWith(imageUrl: value));
  }

  void _toggleMenuAvailable(int index, bool value) {
    _updateMenuAt(index, (menu) => menu.copyWith(isAvailable: value));
  }

  Future<void> save() async {
    _state = _state.copyWith(isSaving: true);
    notifyListeners();
    try {
      await _storeRepository.syncMyStoreMenus(_withReindexedMenus(_state.menus));
      _eventController.add(const PartnerStoreMenuEvent.showMessage('메뉴가 저장되었습니다.'));
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
