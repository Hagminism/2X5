import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_onboarding_action.freezed.dart';

@freezed
sealed class AdminOnboardingAction with _$AdminOnboardingAction {
  const factory AdminOnboardingAction.changeRepresentativeName(String name) =
      ChangeRepresentativeName;

  const factory AdminOnboardingAction.changeBusinessNumber(
    String businessNumber,
  ) = ChangeBusinessNumber;

  const factory AdminOnboardingAction.tapVerifyBusinessNumber() =
      TapVerifyBusinessNumber;

  const factory AdminOnboardingAction.tapPickOpenedOn() = TapPickOpenedOn;

  const factory AdminOnboardingAction.changeOpenedOn(DateTime openedOn) =
      ChangeOpenedOn;

  const factory AdminOnboardingAction.tapPickLicenseImage() =
      TapPickLicenseImage;

  const factory AdminOnboardingAction.changeLicenseImageUrl(String imageUrl) =
      ChangeLicenseImageUrl;

  const factory AdminOnboardingAction.tapRefreshStatus() = TapRefreshStatus;

  const factory AdminOnboardingAction.tapRetrySubmit() = TapRetrySubmit;

  const factory AdminOnboardingAction.tapSubmit() = TapSubmit;
}
