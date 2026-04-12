import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_event.freezed.dart';

@freezed
sealed class SignInEvent with _$SignInEvent {
  const factory SignInEvent.showGoogleSignInError(String error) =
      ShowGoogleSignInError;

  const factory SignInEvent.showNaverSignInError(String error) =
      ShowNaverSignInError;
}
