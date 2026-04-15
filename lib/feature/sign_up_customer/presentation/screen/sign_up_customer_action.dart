import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_customer_action.freezed.dart';

@freezed
sealed class SignUpCustomerAction with _$SignUpCustomerAction {
  const factory SignUpCustomerAction.toggleTermsAgreement() =
      ToggleTermsAgreement;

  const factory SignUpCustomerAction.changePasswordObscureText() =
      ChangePasswordObscureText;

  const factory SignUpCustomerAction.changePasswordConfirmObscureText() =
      ChangePasswordConfirmObscureText;

  const factory SignUpCustomerAction.tapBackButton() = TapBackButton;

  const factory SignUpCustomerAction.tapSubmit() = TapSubmit;
}
