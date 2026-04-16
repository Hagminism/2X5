import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

part 'account_setting_event.freezed.dart';

@freezed
sealed class AccountSettingEvent with _$AccountSettingEvent {
  const factory AccountSettingEvent.showChangePasswordDialog() =
      ShowChangePasswordDialog;

  const factory AccountSettingEvent.showSignOutDialog() = ShowSignOutDialog;

  const factory AccountSettingEvent.showEnterPasswordDialog() =
      ShowEnterPasswordDialog;

  const factory AccountSettingEvent.showDeleteAccountDialog() =
      ShowDeleteAccountDialog;

  const factory AccountSettingEvent.showErrorMessage(String error) =
      ShowshowErrorMessage;
}
