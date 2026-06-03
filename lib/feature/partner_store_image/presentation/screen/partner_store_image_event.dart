import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_store_image_event.freezed.dart';

@freezed
sealed class PartnerStoreImageEvent with _$PartnerStoreImageEvent {
  const factory PartnerStoreImageEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMessage;
  const factory PartnerStoreImageEvent.openGallery() = OpenGallery;
  const factory PartnerStoreImageEvent.pop() = Pop;
}
