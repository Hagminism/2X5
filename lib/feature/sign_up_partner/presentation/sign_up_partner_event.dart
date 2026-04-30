import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_partner_event.freezed.dart';

@freezed
sealed class SignUpPartnerEvent with _$SignUpPartnerEvent {
  const factory SignUpPartnerEvent.showSignUpError(String message) =
      ShowSignUpError;
}
