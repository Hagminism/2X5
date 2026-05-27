import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_event.freezed.dart';

@freezed
sealed class BookmarkEvent with _$BookmarkEvent {
  const factory BookmarkEvent.showSnackBar(String message) = ShowSnackBar;
}
