import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'search_store_information_event.freezed.dart';

@freezed
sealed class SearchStoreInformationEvent with _$SearchStoreInformationEvent {
  const factory SearchStoreInformationEvent.pop() =
      PopSearchStoreInformationScreen;

  const factory SearchStoreInformationEvent.push(String location) =
      PushSearchStoreInformationRoute;

  const factory SearchStoreInformationEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowSearchStoreInformationSnackBar;

  const factory SearchStoreInformationEvent.share({
    required String text,
    String? subject,
  }) = ShareSearchStoreInformationContent;
}
