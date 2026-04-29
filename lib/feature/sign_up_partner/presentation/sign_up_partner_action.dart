import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_partner_action.freezed.dart';

@freezed
sealed class SignUpPartnerAction with _$SignUpPartnerAction {
  const factory SignUpPartnerAction.toggleTermsAgreement() =
      ToggleTermsAgreement;

  const factory SignUpPartnerAction.changeName(String name) = ChangeName;

  const factory SignUpPartnerAction.changePhone(String phone) = ChangePhone;

  const factory SignUpPartnerAction.changeEmail(String email) = ChangeEmail;

  const factory SignUpPartnerAction.changePassword(String password) =
      ChangePassword;

  const factory SignUpPartnerAction.changePasswordConfirm(
    String passwordConfirm,
  ) = ChangePasswordConfirm;

  const factory SignUpPartnerAction.changePasswordObscureText() =
      ChangePasswordObscureText;

  const factory SignUpPartnerAction.changePasswordConfirmObscureText() =
      ChangePasswordConfirmObscureText;

  const factory SignUpPartnerAction.tapBackButton() = TapBackButton;

  const factory SignUpPartnerAction.tapSubmit() = TapSubmit;
}
