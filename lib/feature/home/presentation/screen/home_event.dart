import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'home_event.freezed.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory HomeEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowSnackBar;
}
