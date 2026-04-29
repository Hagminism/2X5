import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_onboarding_state.freezed.dart';

@freezed
abstract class PartnerOnboardingState with _$PartnerOnboardingState {
  const PartnerOnboardingState._();

  const factory PartnerOnboardingState({
    @Default('') String representativeName,
    @Default('') String businessNumber,
    DateTime? openedOn,
    String? licenseImageUrl,
    @Default(false) bool isVerifyingBusinessNumber,
    @Default(false) bool isBusinessNumberVerified,
    @Default(false) bool isUploadingLicenseImage,
    @Default(false) bool isSubmitting,
    @Default(false) bool isPending,
    @Default(false) bool isRejected,
    @Default(false) bool isRefreshingStatus,
  }) = _PartnerOnboardingState;

  bool get canSubmit {
    return representativeName.trim().isNotEmpty &&
        isBusinessNumberVerified &&
        openedOn != null &&
        licenseImageUrl != null &&
        !isVerifyingBusinessNumber &&
        !isUploadingLicenseImage &&
        !isSubmitting &&
        !isPending &&
        !isRejected;
  }
}
