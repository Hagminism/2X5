import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_action.freezed.dart';

@freezed
sealed class BookmarkAction with _$BookmarkAction {
  const factory BookmarkAction.refresh() = RefreshBookmarks;

  const factory BookmarkAction.retryLoad() = RetryLoadBookmarks;

  const factory BookmarkAction.selectCategory(String? category) =
      SelectBookmarkCategory;

  const factory BookmarkAction.tapStore(String storeId) = TapBookmarkStore;

  const factory BookmarkAction.removeBookmark(String storeId) =
      RemoveBookmark;

  const factory BookmarkAction.tapExplore() = TapExploreStores;
}
