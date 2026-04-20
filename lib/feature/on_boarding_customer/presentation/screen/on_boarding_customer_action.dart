import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_customer_action.freezed.dart';

@freezed
sealed class OnBoardingCustomerAction with _$OnBoardingCustomerAction {
  const factory OnBoardingCustomerAction.toggleTermsAgreement() =
      ToggleTermsAgreement;

  const factory OnBoardingCustomerAction.changeName(String name) = ChangeName;

  const factory OnBoardingCustomerAction.changePhone(String phone) = ChangePhone;

  const factory OnBoardingCustomerAction.changeEmail(String email) = ChangeEmail;

  const factory OnBoardingCustomerAction.changePassword(String password) =
      ChangePassword;

  const factory OnBoardingCustomerAction.changePasswordConfirm(
    String passwordConfirm,
  ) = ChangePasswordConfirm;

  const factory OnBoardingCustomerAction.changePasswordObscureText() =
      ChangePasswordObscureText;

  const factory OnBoardingCustomerAction.changePasswordConfirmObscureText() =
      ChangePasswordConfirmObscureText;

  const factory OnBoardingCustomerAction.tapBackButton() = TapBackButton;

  const factory OnBoardingCustomerAction.tapSubmit(
  ) = TapSubmit;
}
