import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_onboarding_event.freezed.dart';

@freezed
sealed class PartnerOnboardingEvent with _$PartnerOnboardingEvent {
  const factory PartnerOnboardingEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMessage;

  const factory PartnerOnboardingEvent.showDatePicker(DateTime? initialDate) =
      ShowDatePicker;

  const factory PartnerOnboardingEvent.showMockGalleryPicker() =
      ShowMockGalleryPicker;
}
