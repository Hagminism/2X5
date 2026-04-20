import 'package:freezed_annotation/freezed_annotation.dart';

part 'on_boarding_customer_event.freezed.dart';

@freezed
sealed class OnBoardingCustomerEvent with _$OnBoardingCustomerEvent {
  const factory OnBoardingCustomerEvent.showSignUpError(String message) =
      ShowGoogleSignUpError;
}
