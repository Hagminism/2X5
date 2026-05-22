import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_action.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_event.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_state.dart';
import 'package:flutter/material.dart';

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

      final imagesList = await Future.wait(
        stores.map((store) => _storeRepository.getStoreImagesByStoreId(store.id)),
      );

      final Map<String, String?> storeImageMap = <String, String?>{};
      for (int i = 0; i < stores.length; i++) {
        final store = stores[i];
        final images = imagesList[i];
        if (images.isNotEmpty) {
          final coverImage = images.firstWhere(
            (img) => img.isCover,
            orElse: () => images.first,
          );
          storeImageMap[store.id] = coverImage.imageUrl;
        }
      }

      final myBookmarks = await _bookmarkRepository.getMyBookmarks();
      final bookmarkedIds = myBookmarks.map((item) => item.storeId).toSet();

      final recommendedStores = _pickOneStorePerCategory(
        stores,
        storeImageMap,
        bookmarkedIds,
      );

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

  List<HomeStoreItem> _pickOneStorePerCategory(
    List<Store> stores,
    Map<String, String?> storeImageMap,
    Set<String> bookmarkedIds,
  ) {
    final Map<StoreCategory, HomeStoreItem> selectedByCategory =
        <StoreCategory, HomeStoreItem>{};

    for (final store in stores) {
      final category = StoreCategory.fromDbValue(store.category);
      if (category == null) {
        continue;
      }

      final current = selectedByCategory[category];
      final isParisBaguette = store.name.contains('파리바게트');

      if (current == null || isParisBaguette) {
        selectedByCategory[category] = HomeStoreItem(
          storeId: store.id,
          name: store.name,
          subtitle: '${category.displayName} · ${store.address}',
          rating: store.rating,
          category: category.displayName,
          imageUrl: storeImageMap[store.id],
          showRating: store.isOnboarded,
          isBookmarked: bookmarkedIds.contains(store.id),
        );
      }
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