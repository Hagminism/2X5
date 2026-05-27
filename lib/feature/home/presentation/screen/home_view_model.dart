import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/model/store/store_list_entry.dart';
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

  static const int _pageSize = 15;
  static const double _radiusMeters = 5000;

  /// UI에 바인딩하지 않는 데이터 풀(거리/카테고리 필터·페이징 소스).
  final List<StoreListEntry> _poolEntries = [];

  final StreamController<HomeEvent> _eventController =
      StreamController<HomeEvent>.broadcast();

  Stream<HomeEvent> get eventStream => _eventController.stream;

  void onAction(HomeAction action) {
    switch (action) {
      case LoadHomeData():
      case RetryLoadHomeData():
        unawaited(_loadStores(reset: true));
        break;
      case LoadMoreStores():
        unawaited(_loadMoreStores());
        break;
      case ShowSoonMessage():
        _eventController.add(HomeEvent.showSnackBar(action.message));
        break;
      case TapHomeBookmark(:final storeId):
        unawaited(_toggleBookmark(storeId));
        break;
      case SelectCategory(:final category):
        _state = state.copyWith(selectedCategory: category);
        _publishFirstPage(
          serverPageFull:
              !state.usesDistancePaging && _poolEntries.length >= _pageSize,
        );
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

  Future<void> refresh() => _loadStores(reset: true);

  Future<void> _loadStores({required bool reset}) async {
    if (state.isLoading) {
      return;
    }

    _state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      visibleStoreCount: 0,
      recommendedStores: reset
          ? const <HomeStoreItem>[]
          : state.recommendedStores,
    );
    notifyListeners();

    try {
      final position = await _getCurrentPosition();
      final usesDistancePaging = position != null;

      _poolEntries.clear();

      if (usesDistancePaging) {
        final entries = await _storeRepository.findStoresNearWithCoverImages(
          latitude: position.latitude,
          longitude: position.longitude,
          radiusMeters: _radiusMeters,
        );
        _poolEntries.addAll(
          entries.where((entry) {
            final store = entry.store;
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              store.latitude,
              store.longitude,
            );
            return distance <= _radiusMeters;
          }),
        );
        _poolEntries.sort(
          (a, b) =>
              _distanceMeters(
                a.store,
                latitude: position.latitude,
                longitude: position.longitude,
              ).compareTo(
                _distanceMeters(
                  b.store,
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              ),
        );
      } else {
        final firstPage = await _storeRepository.findStoresPageWithCoverImages(
          from: 0,
          to: _pageSize - 1,
        );
        _poolEntries.addAll(firstPage);
      }

      final myBookmarks = await _bookmarkRepository.getMyBookmarks();
      final bookmarkedIds = myBookmarks.map((item) => item.storeId).toSet();

      _state = state.copyWith(
        isLoading: false,
        usesDistancePaging: usesDistancePaging,
        userLatitude: position?.latitude,
        userLongitude: position?.longitude,
        bookmarkedStoreIds: bookmarkedIds,
      );
      _publishFirstPage(
        serverPageFull: !usesDistancePaging && _poolEntries.length >= _pageSize,
      );
    } catch (error) {
      _state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        visibleStoreCount: 0,
        recommendedStores: const <HomeStoreItem>[],
      );
      _eventController.add(
        const HomeEvent.showSnackBar('업장 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.'),
      );
      notifyListeners();
    }
  }

  Future<void> _loadMoreStores() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    _state = state.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      if (state.usesDistancePaging) {
        _appendNextPageFromPool(serverPageFull: false);
        return;
      }

      final from = _poolEntries.length;
      final to = from + _pageSize - 1;
      final nextPage = await _storeRepository.findStoresPageWithCoverImages(
        from: from,
        to: to,
      );
      _poolEntries.addAll(nextPage);
      _appendNextPageFromPool(
        serverPageFull: nextPage.length >= _pageSize,
      );
    } catch (_) {
      _state = state.copyWith(isLoadingMore: false);
      notifyListeners();
    }
  }

  void _publishFirstPage({required bool serverPageFull}) {
    final sorted = _filteredPoolEntries();
    final firstSlice = sorted.take(_pageSize).toList(growable: false);

    _state = state.copyWith(
      visibleStoreCount: firstSlice.length,
      recommendedStores: firstSlice.map(_toHomeStoreItem).toList(),
      hasMore: _resolveHasMore(
        sortedLength: sorted.length,
        visibleCount: firstSlice.length,
        serverPageFull: serverPageFull,
      ),
      isLoadingMore: false,
    );
    notifyListeners();
  }

  bool _resolveHasMore({
    required int sortedLength,
    required int visibleCount,
    required bool serverPageFull,
  }) {
    if (state.usesDistancePaging) {
      return visibleCount < sortedLength;
    }
    return serverPageFull;
  }

  void _appendNextPageFromPool({required bool serverPageFull}) {
    final sorted = _filteredPoolEntries();
    final visibleCount = state.visibleStoreCount;

    if (visibleCount >= sorted.length) {
      if (!state.usesDistancePaging && serverPageFull) {
        _state = state.copyWith(isLoadingMore: false);
        notifyListeners();
        return;
      }
      _state = state.copyWith(hasMore: false, isLoadingMore: false);
      notifyListeners();
      return;
    }

    final nextSlice = sorted
        .skip(visibleCount)
        .take(_pageSize)
        .toList(growable: false);
    final newVisibleCount = visibleCount + nextSlice.length;

    _state = state.copyWith(
      visibleStoreCount: newVisibleCount,
      recommendedStores: [
        ...state.recommendedStores,
        ...nextSlice.map(_toHomeStoreItem),
      ],
      hasMore: _resolveHasMore(
        sortedLength: sorted.length,
        visibleCount: newVisibleCount,
        serverPageFull: serverPageFull,
      ),
      isLoadingMore: false,
    );
    notifyListeners();
  }

  List<StoreListEntry> _filteredPoolEntries() {
    final category = state.selectedCategory;
    if (category == null) {
      return List<StoreListEntry>.from(_poolEntries);
    }
    return _poolEntries
        .where(
          (entry) =>
              StoreCategory.fromDbValue(entry.store.category) == category,
        )
        .toList();
  }

  HomeStoreItem _toHomeStoreItem(StoreListEntry entry) {
    final store = entry.store;
    final category = StoreCategory.fromDbValue(store.category);
    return HomeStoreItem(
      storeId: store.id,
      name: store.name,
      subtitle: _distanceText(store),
      rating: store.rating,
      category: category?.displayName ?? store.category,
      imageUrl: entry.coverImageUrl,
      isBookmarked: state.bookmarkedStoreIds.contains(store.id),
      showRating: store.ownerId.trim().isNotEmpty,
    );
  }

  String _distanceText(Store store) {
    final lat = state.userLatitude;
    final lng = state.userLongitude;
    if (lat == null || lng == null) {
      return store.address;
    }
    final meters = _distanceMeters(store, latitude: lat, longitude: lng);
    final distanceLabel = meters < 1000
        ? '${meters.round()}m'
        : '${(meters / 1000).toStringAsFixed(1)}km';
    return '$distanceLabel · ${store.address}';
  }

  double _distanceMeters(
    Store store, {
    required double latitude,
    required double longitude,
  }) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      store.latitude,
      store.longitude,
    );
  }

  Future<void> _toggleBookmark(String storeId) async {
    final index = state.recommendedStores.indexWhere(
      (item) => item.storeId == storeId,
    );
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

      final updatedBookmarkIds = Set<String>.from(state.bookmarkedStoreIds);
      if (wasBookmarked) {
        updatedBookmarkIds.remove(storeId);
      } else {
        updatedBookmarkIds.add(storeId);
      }

      final updatedStores = [...state.recommendedStores];
      updatedStores[index] = item.copyWith(isBookmarked: !wasBookmarked);

      _state = state.copyWith(
        recommendedStores: updatedStores,
        bookmarkedStoreIds: updatedBookmarkIds,
      );
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
