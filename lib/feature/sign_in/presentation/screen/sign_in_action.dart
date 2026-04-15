import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_action.freezed.dart';

@freezed
sealed class SignInAction with _$SignInAction {
  const factory SignInAction.changeObscureText() = ChangeObscureText;

  const factory SignInAction.changeEmail(String email) = ChangeEmail;

  const factory SignInAction.changePassword(String password) =
  ChangePassword;

  const factory SignInAction.tapSignInButton() = TapSignInButton;

  const factory SignInAction.moveToSignUpScreen() = MoveToSignUpScreen;

  const factory SignInAction.moveToFindPasswordScreen() =
      MoveToFindPasswordScreen;

  const factory SignInAction.tapGoogleSignInButton() = TapGoogleSignInButton;

  const factory SignInAction.tapNaverSignInButton() = TapNaverSignInButton;

  const factory SignInAction.tapKakaoSignInButton() = TapKakaoSignInButton;
}
