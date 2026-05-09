import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_action.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_event.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_state.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  HomeViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  HomeState _state = const HomeState();

  HomeState get state => _state;

  final StreamController<HomeEvent> _eventController =
      StreamController<HomeEvent>.broadcast();

  Stream<HomeEvent> get eventStream => _eventController.stream;

  void onAction(HomeAction action) {
    switch (action) {
      case LoadHomeData():
      case RetryLoadHomeData():
        _loadStores();
        break;
      case ShowSoonMessage():
        _eventController.add(HomeEvent.showSnackBar(action.message));
        break;
    }
  }

  Future<void> _loadStores() async {
    if (state.isLoading) {
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final stores = await _storeRepository.getStores();
      final recommendedStores = _pickOneStorePerCategory(stores);

      _state = state.copyWith(
        isLoading: false,
        recommendedStores: recommendedStores,
      );
      notifyListeners();
    } catch (error) {
      _state = state.copyWith(
        isLoading: false,
        recommendedStores: const <HomeStoreItem>[],
      );
      _eventController.add(
        const HomeEvent.showSnackBar('업장 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.'),
      );
      notifyListeners();
    }
  }

  List<HomeStoreItem> _pickOneStorePerCategory(List<Store> stores) {
    final Map<StoreCategory, HomeStoreItem> selectedByCategory =
        <StoreCategory, HomeStoreItem>{};

    for (final store in stores) {
      final category = StoreCategory.fromDbValue(store.category);
      if (category == null || selectedByCategory.containsKey(category)) {
        continue;
      }

      selectedByCategory[category] = HomeStoreItem(
        storeId: store.id,
        name: store.name,
        subtitle: '${category.displayName} · ${store.address}',
        rating: store.rating,
        category: category.displayName,
      );
    }

    final List<HomeStoreItem> orderedStores = <HomeStoreItem>[];
    for (final category in StoreCategory.values) {
      final store = selectedByCategory[category];
      if (store != null) {
        orderedStores.add(store);
      }
    }
    return orderedStores;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
