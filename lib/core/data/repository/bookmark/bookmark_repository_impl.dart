import 'dart:async';

import 'package:capstone_2026/core/data/data_source/bookmark/bookmark_data_source.dart';
import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:flutter/foundation.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  BookmarkRepositoryImpl({
    required BookmarkDataSource bookmarkDataSource,
    required AuthRepository authRepository,
  }) : _bookmarkDataSource = bookmarkDataSource,
       _authRepository = authRepository {
    _authRepository.authStateChanges().listen((user) {
      if (user == null) {
        stopWatching();
        clearCache();
        return;
      }
      startWatching();
    });

    if (_authRepository.getCurrentUser() != null) {
      startWatching();
    }
  }

  final BookmarkDataSource _bookmarkDataSource;
  final AuthRepository _authRepository;

  final StreamController<List<BookmarkListItem>> _bookmarksController =
      StreamController<List<BookmarkListItem>>.broadcast();
  final StreamController<Set<String>> _bookmarkedIdsController =
      StreamController<Set<String>>.broadcast();

  StreamSubscription<List<Map<String, dynamic>>>? _watchSubscription;
  Timer? _debounceTimer;

  List<BookmarkListItem> _cachedBookmarks = const [];
  Set<String> _cachedBookmarkedIds = const {};
  String? _watchingUserId;
  bool _hasLoadedOnce = false;

  String _requireUserId() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('로그인이 필요합니다.');
    }
    return userId;
  }

  @override
  Stream<List<BookmarkListItem>> watchMyBookmarks() {
    return Stream<List<BookmarkListItem>>.multi((controller) {
      controller.add(List<BookmarkListItem>.unmodifiable(_cachedBookmarks));
      final subscription = _bookmarksController.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Stream<Set<String>> watchBookmarkedStoreIds() {
    return Stream<Set<String>>.multi((controller) {
      controller.add(Set<String>.unmodifiable(_cachedBookmarkedIds));
      final subscription = _bookmarkedIdsController.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  void startWatching() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      return;
    }
    if (_watchingUserId == userId && _watchSubscription != null) {
      return;
    }

    stopWatching();
    _watchingUserId = userId;

    _watchSubscription = _bookmarkDataSource.watchByUserId(userId).listen(
      (rows) {
        _applyRows(rows);
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('북마크 Realtime 구독 오류: $error\n$stack');
      },
    );
  }

  @override
  void stopWatching() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    unawaited(_watchSubscription?.cancel());
    _watchSubscription = null;
    _watchingUserId = null;
  }

  @override
  void clearCache() {
    _cachedBookmarks = const [];
    _cachedBookmarkedIds = const {};
    _hasLoadedOnce = false;
    _emit();
  }

  @override
  Future<void> refresh() async {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      clearCache();
      return;
    }

    try {
      final rows = await _bookmarkDataSource.findByUserId(userId);
      _applyRows(rows);
    } catch (error, stack) {
      debugPrint('북마크 refresh 실패: $error\n$stack');
      rethrow;
    }
  }

  void _applyRows(List<Map<String, dynamic>> rows) {
    _cachedBookmarks = rows.map(_mapRow).whereType<BookmarkListItem>().toList();
    _cachedBookmarkedIds = _cachedBookmarks.map((item) => item.storeId).toSet();
    _hasLoadedOnce = true;
    _emit();
  }

  void _emit() {
    if (!_bookmarksController.isClosed) {
      _bookmarksController.add(List<BookmarkListItem>.unmodifiable(_cachedBookmarks));
    }
    if (!_bookmarkedIdsController.isClosed) {
      _bookmarkedIdsController.add(Set<String>.unmodifiable(_cachedBookmarkedIds));
    }
  }

  void _scheduleRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(refresh());
    });
  }

  @override
  Future<bool> isBookmarked(String storeId) async {
    if (_hasLoadedOnce) {
      return _cachedBookmarkedIds.contains(storeId);
    }

    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      return false;
    }
    return _bookmarkDataSource.exists(userId: userId, storeId: storeId);
  }

  @override
  Future<void> addBookmark(String storeId) async {
    final userId = _requireUserId();
    await _bookmarkDataSource.add(userId: userId, storeId: storeId);
    _scheduleRefresh();
  }

  @override
  Future<void> removeBookmark(String storeId) async {
    final userId = _requireUserId();
    await _bookmarkDataSource.remove(userId: userId, storeId: storeId);
    _scheduleRefresh();
  }

  @override
  Future<List<BookmarkListItem>> getMyBookmarks() async {
    if (_hasLoadedOnce) {
      return List<BookmarkListItem>.unmodifiable(_cachedBookmarks);
    }

    final userId = _requireUserId();
    final rows = await _bookmarkDataSource.findByUserId(userId);
    _applyRows(rows);
    return List<BookmarkListItem>.unmodifiable(_cachedBookmarks);
  }

  BookmarkListItem? _mapRow(Map<String, dynamic> row) {
    final store = row['stores'];
    if (store is! Map<String, dynamic>) {
      return null;
    }

    final ratingRaw = store['rating'];
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;

    return BookmarkListItem(
      bookmarkId: row['id']?.toString() ?? '',
      storeId: row['store_id']?.toString() ?? store['id']?.toString() ?? '',
      name: store['name']?.toString() ?? '',
      category: store['category']?.toString() ?? '',
      address: store['address']?.toString() ?? '',
      rating: rating,
      reviewCount: _reviewCountFromStore(store),
      imageUrl: _firstStoreImageUrl(store['store_images']),
      bookmarkedAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
    );
  }

  int _reviewCountFromStore(Map<String, dynamic> store) {
    final raw = store['reviews'];
    if (raw is! List || raw.isEmpty) {
      return 0;
    }

    final first = raw.first;
    if (first is! Map<String, dynamic>) {
      return 0;
    }

    final count = first['count'];
    if (count is num) {
      return count.toInt();
    }

    return 0;
  }

  String? _firstStoreImageUrl(dynamic rawImages) {
    if (rawImages is! List) {
      return null;
    }

    final images = rawImages
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => StoreImage(
            id: json['id']?.toString(),
            imageUrl: json['image_url']?.toString() ?? '',
            sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
            isCover: json['is_cover'] as bool? ?? false,
          ),
        )
        .toList();

    return storeHeaderImageUrl(images);
  }
}
