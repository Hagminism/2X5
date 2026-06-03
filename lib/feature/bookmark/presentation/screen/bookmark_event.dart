import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'bookmark_event.freezed.dart';

@freezed
sealed class BookmarkEvent with _$BookmarkEvent {
  const factory BookmarkEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowSnackBar;
}
