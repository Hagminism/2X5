import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_customer_action.freezed.dart';

@freezed
sealed class SignUpCustomerAction with _$SignUpCustomerAction {
  const factory SignUpCustomerAction.toggleTermsAgreement() =
      ToggleTermsAgreement;

  const factory SignUpCustomerAction.changeName(String name) = ChangeName;

  const factory SignUpCustomerAction.changePhone(String phone) = ChangePhone;

  const factory SignUpCustomerAction.changeEmail(String email) = ChangeEmail;

  const factory SignUpCustomerAction.changePassword(String password) =
      ChangePassword;

  const factory SignUpCustomerAction.changePasswordConfirm(
    String passwordConfirm,
  ) = ChangePasswordConfirm;

  const factory SignUpCustomerAction.changePasswordObscureText() =
      ChangePasswordObscureText;

  const factory SignUpCustomerAction.changePasswordConfirmObscureText() =
      ChangePasswordConfirmObscureText;

  const factory SignUpCustomerAction.tapBackButton() = TapBackButton;

  const factory SignUpCustomerAction.tapSubmit() = TapSubmit;
}
