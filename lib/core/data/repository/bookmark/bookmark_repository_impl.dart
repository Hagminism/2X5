import 'package:capstone_2026/core/data/data_source/bookmark/bookmark_data_source.dart';
import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/bookmark/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  const BookmarkRepositoryImpl({
    required BookmarkDataSource bookmarkDataSource,
    required AuthRepository authRepository,
  }) : _bookmarkDataSource = bookmarkDataSource,
       _authRepository = authRepository;

  final BookmarkDataSource _bookmarkDataSource;
  final AuthRepository _authRepository;

  String _requireUserId() {
    final userId = _authRepository.getCurrentUser()?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('로그인이 필요합니다.');
    }
    return userId;
  }

  @override
  Future<bool> isBookmarked(String storeId) async {
    final userId = _requireUserId();
    return _bookmarkDataSource.exists(userId: userId, storeId: storeId);
  }

  @override
  Future<void> addBookmark(String storeId) async {
    final userId = _requireUserId();
    await _bookmarkDataSource.add(userId: userId, storeId: storeId);
  }

  @override
  Future<void> removeBookmark(String storeId) async {
    final userId = _requireUserId();
    await _bookmarkDataSource.remove(userId: userId, storeId: storeId);
  }

  @override
  Future<List<BookmarkListItem>> getMyBookmarks() async {
    final userId = _requireUserId();
    final rows = await _bookmarkDataSource.findByUserId(userId);

    return rows.map(_mapRow).whereType<BookmarkListItem>().toList();
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
      bookmarkedAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
    );
  }
}