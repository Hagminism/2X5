import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'map_store_information_event.freezed.dart';

@freezed
sealed class MapStoreInformationEvent with _$MapStoreInformationEvent {
  const factory MapStoreInformationEvent.pop() = PopMapStoreInformationScreen;

  const factory MapStoreInformationEvent.push(String location) =
      PushMapStoreInformationRoute;

  const factory MapStoreInformationEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMapStoreInformationSnackBar;

  const factory MapStoreInformationEvent.share({
    required String text,
    String? subject,
  }) = ShareMapStoreInformationContent;
}
