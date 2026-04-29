import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_onboarding_event.freezed.dart';

@freezed
sealed class PartnerOnboardingEvent with _$PartnerOnboardingEvent {
  const factory PartnerOnboardingEvent.showMessage(String message) = ShowMessage;

  const factory PartnerOnboardingEvent.showDatePicker(DateTime? initialDate) =
      ShowDatePicker;

  const factory PartnerOnboardingEvent.showMockGalleryPicker() =
      ShowMockGalleryPicker;
}
