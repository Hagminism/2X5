import 'dart:async';

import 'package:capstone_2026/core/presentation/component/dialog/app_confirm_dialog.dart';
import 'package:capstone_2026/core/presentation/component/dialog/text_field_dialog.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_action.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_event.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_screen.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettingScreenRoot extends StatefulWidget {
  final AccountSettingViewModel viewModel;

  const AccountSettingScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<AccountSettingScreenRoot> createState() =>
      _AccountSettingScreenRootState();
}

class _AccountSettingScreenRootState extends State<AccountSettingScreenRoot> {
  StreamSubscription<AccountSettingEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen(
      (event) async {
        if (mounted) {
          switch (event) {
            case ShowChangePasswordDialog():
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(title: Text('비밀번호 변경'));
                },
              );
              break;
            case ShowSignOutDialog():
              final confirmed = await showAppConfirmDialog(
                context,
                title: '로그아웃',
                message: '정말 로그아웃 하시겠습니까?',
              );
              if (confirmed && mounted) {
                widget.viewModel.onAction(
                  AccountSettingAction.tapSignOutConfirmButton(),
                );
              }
              break;
            case ShowDeleteAccountDialog():
              final confirmed = await showAppConfirmDialog(
                context,
                title: '회원 탈퇴',
                message: '정말로 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
                confirmLabel: '탈퇴',
                variant: AppConfirmDialogVariant.destructive,
              );
              if (confirmed && mounted) {
                widget.viewModel.onAction(
                  AccountSettingAction.tapDeleteAccountConfirmButton(),
                );
              }
              break;
            case ShowEnterPasswordDialog():
              showDialog(
                context: context,
                builder: (context) {
                  return TextFieldDialog(
                    title: '탈퇴를 원하시면 비밀번호를 재입력해주세요.',
                    onPressed: () {
                      widget.viewModel.onAction(
                        AccountSettingAction.tapSubmitPasswordButton(),
                      );
                    },
                    onChanged: (password) {
                      widget.viewModel.onAction(
                        AccountSettingAction.typePassword(password),
                      );
                    },
                  );
                },
              );
              break;
            case ShowshowErrorMessage(:final error):
              AppSnackBar.showError(context, error);
              break;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return AccountSettingScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapBackButton():
                context.pop();
                break;
              case TapChangePasswordButton():
              case TapSignOutButton():
              case TapSignOutConfirmButton():
              case TapDeleteAccountButton():
              case TapDeleteAccountConfirmButton():
              case TapSubmitPasswordButton():
              case TypePassword():
                widget.viewModel.onAction(action);
                break;
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
