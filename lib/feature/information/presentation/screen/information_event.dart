import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'information_event.freezed.dart';

@freezed
sealed class InformationEvent with _$InformationEvent {
  const factory InformationEvent.pop() = PopInformationScreen;

  const factory InformationEvent.push(String location) = PushInformationRoute;

  const factory InformationEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowInformationSnackBar;

  const factory InformationEvent.share({
    required String text,
    String? subject,
  }) = ShareInformationContent;
}
