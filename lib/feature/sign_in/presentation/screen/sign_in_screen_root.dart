import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_event.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_screen.dart';

class SignInScreenRoot extends StatefulWidget {
  final SignInViewModel viewModel;

  const SignInScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<SignInScreenRoot> createState() => _SignInScreenRootState();
}

class _SignInScreenRootState extends State<SignInScreenRoot> {
  StreamSubscription<SignInEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen(
      (event) {
        if (mounted) {
          switch (event) {
            case ShowGoogleSignInError():
            case ShowNaverSignInError():
              // TODO: 스낵바 디자인은 기본 디자인으로 임시 사용
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(event.error),
                  duration: Duration(milliseconds: 1500),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return SignInScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case ChangeObscureText():
              case TapGoogleSignInButton():
              case TapNaverSignInButton():
              case TapKakaoSignInButton():
                widget.viewModel.onAction(action);
                break;
              case TapSignInButton():
                // 이메일 로그인 구현 시 연결
                break;
              case MoveToSignUpScreen():
                context.go('${Routes.signIn}/${Routes.selectAuthProvider}');
                break;
              case MoveToFindPasswordScreen():
                context.go('${Routes.signIn}/${Routes.findPassword}');
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
