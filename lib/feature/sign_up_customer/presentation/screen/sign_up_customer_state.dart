import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_customer_state.freezed.dart';

@freezed
abstract class SignUpCustomerState with _$SignUpCustomerState {
  const SignUpCustomerState._();

  const factory SignUpCustomerState({
    @Default(false) bool isLoading,
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String passwordConfirm,
    @Default(false) bool agreeTerms,
    @Default(true) bool passwordObscureText,
    @Default(true) bool passwordConfirmObscureText,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _SignUpCustomerState;
}
