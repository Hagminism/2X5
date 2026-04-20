import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_customer_state.freezed.dart';

@freezed
abstract class OnBoardingCustomerState with _$OnBoardingCustomerState {
  const OnBoardingCustomerState._();

  const factory OnBoardingCustomerState({
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
  }) = _OnBoardingCustomerState;
}
