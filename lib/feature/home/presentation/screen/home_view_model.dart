import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_action.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_event.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomeViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final BookmarkRepository _bookmarkRepository;

  HomeViewModel({
    required StoreRepository storeRepository,
    required BookmarkRepository bookmarkRepository,
  }) : _storeRepository = storeRepository,
       _bookmarkRepository = bookmarkRepository;

  HomeState _state = const HomeState();

  HomeState get state => _state;

  List<Store> _allStores = [];
  Map<String, String?> _storeImageMap = {};
  Set<String> _bookmarkedIds = {};
  Position? _currentPosition;

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
      case TapHomeBookmark(:final storeId):
        unawaited(_toggleBookmark(storeId));
        break;
      case SelectCategory(:final category):
        _state = state.copyWith(
          selectedCategory: category,
          recommendedStores: _buildDisplayStores(category),
        );
        notifyListeners();
        break;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() => _loadStores();

  Future<void> _loadStores() async {
    if (state.isLoading) {
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // 1단계: 가게 목록과 GPS를 병렬로 가져옴
      List<Store> allStores = [];
      Position? position;
      await Future.wait([
        _storeRepository.getStores().then((v) => allStores = v),
        _getCurrentPosition().then((v) => position = v),
      ]);

      final stores = position == null
          ? allStores
          : allStores.where((store) {
              final distance = Geolocator.distanceBetween(
                position!.latitude,
                position!.longitude,
                store.latitude,
                store.longitude,
              );
              return distance <= 5000;
            }).toList();

      final storeIds = stores.map((s) => s.id).toList();

      // 2단계: 커버 이미지 배치 쿼리와 북마크를 병렬로 가져옴
      Map<String, String?> storeImageMap = {};
      List<BookmarkListItem> myBookmarks = [];
      await Future.wait([
        _storeRepository
            .getCoverImageUrlsByStoreIds(storeIds)
            .then((v) => storeImageMap = v),
        _bookmarkRepository.getMyBookmarks().then((v) => myBookmarks = v),
      ]);

      _allStores = stores;
      _storeImageMap = storeImageMap;
      _bookmarkedIds = myBookmarks.map((item) => item.storeId).toSet();
      if (position != null) _currentPosition = position;

      _state = state.copyWith(
        isLoading: false,
        recommendedStores: _buildDisplayStores(state.selectedCategory),
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

  String _distanceText(Store store) {
    if (_currentPosition == null) return store.address;
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      store.latitude,
      store.longitude,
    );
    final distanceLabel = meters < 1000
        ? '${meters.round()}m'
        : '${(meters / 1000).toStringAsFixed(1)}km';
    return '$distanceLabel · ${store.address}';
  }

  double _distanceMeters(Store store) {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      store.latitude,
      store.longitude,
    );
  }

  List<HomeStoreItem> _buildDisplayStores(StoreCategory? selectedCategory) {
    if (selectedCategory != null) {
      final filtered = _allStores
          .where((s) => StoreCategory.fromDbValue(s.category) == selectedCategory)
          .toList()
        ..sort((a, b) => _distanceMeters(a).compareTo(_distanceMeters(b)));
      return filtered
          .map((s) => HomeStoreItem(
                storeId: s.id,
                name: s.name,
                subtitle: _distanceText(s),
                rating: s.rating,
                category: selectedCategory.displayName,
                imageUrl: _storeImageMap[s.id],
                isBookmarked: _bookmarkedIds.contains(s.id),
              ))
          .toList();
    }

    // 전체: 모든 가게 (거리순)
    final sorted = [..._allStores]
      ..sort((a, b) => _distanceMeters(a).compareTo(_distanceMeters(b)));
    return sorted.map((s) {
      final category = StoreCategory.fromDbValue(s.category);
      return HomeStoreItem(
        storeId: s.id,
        name: s.name,
        subtitle: _distanceText(s),
        rating: s.rating,
        category: category?.displayName ?? s.category,
        imageUrl: _storeImageMap[s.id],
        isBookmarked: _bookmarkedIds.contains(s.id),
      );
    }).toList();
  }

  Future<void> _toggleBookmark(String storeId) async {
    final index =
        state.recommendedStores.indexWhere((item) => item.storeId == storeId);
    if (index < 0) {
      return;
    }

    final item = state.recommendedStores[index];
    final wasBookmarked = item.isBookmarked;

    try {
      if (wasBookmarked) {
        await _bookmarkRepository.removeBookmark(storeId);
      } else {
        await _bookmarkRepository.addBookmark(storeId);
      }

      final updatedStores = [...state.recommendedStores];
      updatedStores[index] = item.copyWith(isBookmarked: !wasBookmarked);

      _state = state.copyWith(recommendedStores: updatedStores);
      notifyListeners();

      _eventController.add(
        HomeEvent.showSnackBar(
          wasBookmarked ? '즐겨찾기를 해제했습니다.' : '즐겨찾기에 추가했습니다.',
        ),
      );
    } catch (_) {
      _eventController.add(
        const HomeEvent.showSnackBar('즐겨찾기 처리에 실패했습니다.'),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}