import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_onboarding_event.freezed.dart';

@freezed
sealed class AdminOnboardingEvent with _$AdminOnboardingEvent {
  const factory AdminOnboardingEvent.showMessage(String message) = ShowMessage;

  const factory AdminOnboardingEvent.showDatePicker(DateTime? initialDate) =
      ShowDatePicker;

  const factory AdminOnboardingEvent.showMockGalleryPicker() =
      ShowMockGalleryPicker;
}
