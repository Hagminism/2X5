import 'package:capstone_2026/core/domain/model/bookmark/bookmark_list_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_state.freezed.dart';

@freezed
abstract class BookmarkState with _$BookmarkState {
  const BookmarkState._();

  const factory BookmarkState({
    @Default(<BookmarkListItem>[]) List<BookmarkListItem> items,
    String? selectedCategory,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _BookmarkState;

  List<BookmarkListItem> get visibleItems {
    if (selectedCategory == null) {
      return items;
    }
    return items.where((item) => item.category == selectedCategory).toList();
  }
}
