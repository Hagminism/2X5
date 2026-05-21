import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';
import 'package:flutter/material.dart';

class BookmarkViewModel extends ChangeNotifier {
  BookmarkViewModel({
    required BookmarkRepository bookmarkRepository,
  }) : _bookmarkRepository = bookmarkRepository;

  final BookmarkRepository _bookmarkRepository;

  static const List<String> filters = ['전체', '식당', '카페', '미용실', '스터디카페'];

  List<BookmarkListItem> _items = [];
  String _selectedFilter = '전체';
  bool _isLoading = false;
  String? _errorMessage;

  List<BookmarkListItem> get items => _items;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookmarkListItem> get visibleItems {
    if (_selectedFilter == '전체') {
      return _items;
    }
    return _items
        .where((item) => _categoryLabel(item) == _selectedFilter)
        .toList();
  }

  String _categoryLabel(BookmarkListItem item) {
    return StoreCategory.fromDbValue(item.category)?.displayName ??
        item.category;
  }

  String subtitleFor(BookmarkListItem item) {
    final label = _categoryLabel(item);
    final address = item.address.trim();
    if (address.isEmpty) {
      return label;
    }
    return '$label · $address';
  }

  Future<void> loadBookmarks() async {
    if (_isLoading) {
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

  void selectFilter(String filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
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