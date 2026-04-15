import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_customer_event.freezed.dart';

@freezed
sealed class SignUpCustomerEvent with _$SignUpCustomerEvent {
  const factory SignUpCustomerEvent.showErrorMessage(String message) =
      ShowErrorMessage;
}
