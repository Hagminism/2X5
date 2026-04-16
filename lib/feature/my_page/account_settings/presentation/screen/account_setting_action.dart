import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_setting_action.freezed.dart';

@freezed
sealed class AccountSettingAction with _$AccountSettingAction {
  const factory AccountSettingAction.tapBackButton() = TapBackButton;

  const factory AccountSettingAction.tapChangePasswordButton() =
      TapChangePasswordButton;

  const factory AccountSettingAction.tapSignOutButton() = TapSignOutButton;

  const factory AccountSettingAction.tapSignOutConfirmButton() =
      TapSignOutConfirmButton;

  const factory AccountSettingAction.tapDeleteAccountButton() =
      TapDeleteAccountButton;

  const factory AccountSettingAction.tapDeleteAccountConfirmButton() =
      TapDeleteAccountConfirmButton;

  const factory AccountSettingAction.tapSubmitPasswordButton() =
      TapSubmitPasswordButton;

  const factory AccountSettingAction.typePassword(String password) =
      TypePassword;
}
