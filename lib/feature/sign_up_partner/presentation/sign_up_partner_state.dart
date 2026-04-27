import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_partner_state.freezed.dart';

@freezed
abstract class SignUpPartnerState with _$SignUpPartnerState {
  const SignUpPartnerState._();

  const factory SignUpPartnerState({
    @Default(false) bool isLoading,
    @Default('') String name,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String password,
    @Default('') String passwordConfirm,
    @Default(false) bool agreeTerms,
    @Default(true) bool passwordObscureText,
    @Default(true) bool passwordConfirmObscureText,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _SignUpPartnerState;
}
