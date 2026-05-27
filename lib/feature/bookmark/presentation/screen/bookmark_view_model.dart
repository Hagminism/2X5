import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  BookmarkViewModel({
    required BookmarkRepository bookmarkRepository,
  }) : _bookmarkRepository = bookmarkRepository;

  final BookmarkRepository _bookmarkRepository;

  List<BookmarkListItem> _items = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  List<BookmarkListItem> get items => _items;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookmarkListItem> get visibleItems {
    if (_selectedCategory == null) {
      return _items;
    }
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  Future<void> loadBookmarks({bool force = false}) async {
    if (_isLoading && !force) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _bookmarkRepository.getMyBookmarks();
    } catch (e) {
      _errorMessage = e.toString();
      _items = [];
      debugPrint('북마크 목록 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) {
      return;
    }
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> removeBookmark(String storeId) async {
    try {
      await _bookmarkRepository.removeBookmark(storeId);
      _items = _items.where((item) => item.storeId != storeId).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('북마크 제거 실패: $e');
      rethrow;
    }
  }
}
