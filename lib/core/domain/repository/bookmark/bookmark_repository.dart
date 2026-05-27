import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';

abstract interface class BookmarkRepository {
  Future<bool> isBookmarked(String storeId);

  Future<void> addBookmark(String storeId);

  Future<void> removeBookmark(String storeId);

  Future<List<BookmarkListItem>> getMyBookmarks();
}
