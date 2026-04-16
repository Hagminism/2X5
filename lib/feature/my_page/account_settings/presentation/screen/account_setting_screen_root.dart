import 'dart:async';

import 'package:capstone_2026/core/presentation/component/dialog/text_field_dialog.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/component/dialog/double_button_dialog.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_action.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_view_model.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_screen.dart';

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
      (event) {
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
              showDialog(
                context: context,
                builder: (context) {
                  return DoubleButtonDialog(
                    title: '로그아웃 하시겠습니까?',
                    onPressed: () {
                      widget.viewModel.onAction(
                        AccountSettingAction.tapSignOutConfirmButton(),
                      );
                    },
                  );
                },
              );
              break;
            case ShowDeleteAccountDialog():
              showDialog(
                context: context,
                builder: (context) {
                  return DoubleButtonDialog(
                    title: '정말로 탈퇴하시겠습니까?',
                    onPressed: () {
                      widget.viewModel.onAction(
                        AccountSettingAction.tapDeleteAccountConfirmButton(),
                      );
                    },
                  );
                },
              );
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
            case ShowshowErrorMessage():
              // TODO: 스낵바 디자인은 기본 디자인으로 임시 사용
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(event.error),
                  duration: Duration(milliseconds: 1500),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
