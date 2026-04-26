import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_in_state.freezed.dart';

@freezed
abstract class SignInState with _$SignInState {
  const factory SignInState({
    @Default(false) bool isLoading,
    @Default(true) bool isObscureText,
    @Default('') String email,
    @Default('') String password,
    @Default('') String naverState,
  }) = _SignInState;
}
