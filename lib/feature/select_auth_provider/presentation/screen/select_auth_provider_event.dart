import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_auth_provider_event.freezed.dart';

@freezed
sealed class SelectAuthProviderEvent with _$SelectAuthProviderEvent {
  const factory SelectAuthProviderEvent.showGoogleSignInError(String error) =
      ShowGoogleSignInError;

  const factory SelectAuthProviderEvent.showNaverSignInError(String error) =
      ShowNaverSignInError;
}
