import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_customer_state.freezed.dart';

@freezed
abstract class SignUpCustomerState with _$SignUpCustomerState {
  const SignUpCustomerState._();

  const factory SignUpCustomerState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String passwordConfirm,
    @Default(false) bool agreeTerms,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _SignUpCustomerState;

  bool get isPasswordMatched => password == passwordConfirm;

  bool get canSubmit {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.trim().isNotEmpty &&
        passwordConfirm.trim().isNotEmpty &&
        agreeTerms &&
        !isSubmitting;
  }
}
