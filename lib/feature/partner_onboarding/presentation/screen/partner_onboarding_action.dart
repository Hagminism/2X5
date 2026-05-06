import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_onboarding_action.freezed.dart';

@freezed
sealed class PartnerOnboardingAction with _$PartnerOnboardingAction {
  const factory PartnerOnboardingAction.changeRepresentativeName(String name) =
      ChangeRepresentativeName;

  const factory PartnerOnboardingAction.changeBusinessNumber(
    String businessNumber,
  ) = ChangeBusinessNumber;

  const factory PartnerOnboardingAction.tapVerifyBusinessNumber() =
      TapVerifyBusinessNumber;

  const factory PartnerOnboardingAction.tapPickOpenedOn() = TapPickOpenedOn;

  const factory PartnerOnboardingAction.changeOpenedOn(DateTime openedOn) =
      ChangeOpenedOn;

  const factory PartnerOnboardingAction.tapPickLicenseImage() =
      TapPickLicenseImage;

  const factory PartnerOnboardingAction.changeLicenseImageUrl(String imageUrl) =
      ChangeLicenseImageUrl;

  const factory PartnerOnboardingAction.tapRefreshStatus() = TapRefreshStatus;

  const factory PartnerOnboardingAction.tapRetrySubmit() = TapRetrySubmit;

  const factory PartnerOnboardingAction.tapSubmit() = TapSubmit;
}
