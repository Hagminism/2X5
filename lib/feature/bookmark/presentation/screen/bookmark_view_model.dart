import 'dart:async';

import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_action.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_event.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_state.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  BookmarkViewModel({
    required BookmarkRepository bookmarkRepository,
  }) : _bookmarkRepository = bookmarkRepository;

  final BookmarkRepository _bookmarkRepository;

  BookmarkState _state = const BookmarkState();

  BookmarkState get state => _state;

  StreamSubscription<List<BookmarkListItem>>? _bookmarksSubscription;

  final StreamController<BookmarkEvent> _eventController =
      StreamController<BookmarkEvent>.broadcast();

  Stream<BookmarkEvent> get eventStream => _eventController.stream;

  void initialize() {
    _bookmarksSubscription?.cancel();
    _bookmarksSubscription = _bookmarkRepository.watchMyBookmarks().listen(
      (items) {
        _state = _state.copyWith(
          items: items,
          isLoading: false,
          errorMessage: null,
        );
        notifyListeners();
      },
      onError: (Object error) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          items: const [],
        );
        notifyListeners();
        debugPrint('북마크 목록 구독 실패: $error');
      },
    );

    if (_state.items.isEmpty && !_state.isLoading) {
      _state = _state.copyWith(isLoading: true);
      notifyListeners();
      unawaited(_refresh(force: true));
    }
  }

  void onAction(BookmarkAction action) {
    switch (action) {
      case RefreshBookmarks():
      case RetryLoadBookmarks():
        unawaited(_refresh(force: true));
        break;
      case SelectBookmarkCategory(:final category):
        if (_state.selectedCategory == category) {
          return;
        }
        _state = _state.copyWith(selectedCategory: category);
        notifyListeners();
        break;
      case TapBookmarkStore():
      case TapExploreStores():
        break;
      case RemoveBookmark(:final storeId):
        unawaited(_removeBookmark(storeId));
        break;
    }
  }

  Future<void> _refresh({required bool force}) async {
    if (_state.isLoading && !force) {
      return;
    }

    _state = _state.copyWith(
      isLoading: _state.items.isEmpty,
      errorMessage: null,
    );
    notifyListeners();

    try {
      await _bookmarkRepository.refresh();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      notifyListeners();
      debugPrint('북마크 목록 refresh 실패: $error');
    }
  }

  Future<void> _removeBookmark(String storeId) async {
    try {
      await _bookmarkRepository.removeBookmark(storeId);
      _eventController.add(
        const BookmarkEvent.showSnackBar('저장 목록에서 제거했습니다.', variant: AppSnackBarVariant.success),
      );
    } catch (error) {
      debugPrint('북마크 제거 실패: $error');
      _eventController.add(
        const BookmarkEvent.showSnackBar('제거에 실패했습니다.'),
      );
    }
  }

  @override
  void dispose() {
    _bookmarksSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}
