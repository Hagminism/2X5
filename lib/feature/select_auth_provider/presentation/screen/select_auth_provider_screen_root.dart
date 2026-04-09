import 'dart:async';

import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_action.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_event.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_screen.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/routing/routes.dart';

class SelectAuthProviderScreenRoot extends StatefulWidget {
  final SelectAuthProviderViewModel viewModel;

  const SelectAuthProviderScreenRoot({super.key, required this.viewModel});

  @override
  State<SelectAuthProviderScreenRoot> createState() =>
      _SelectAuthProviderScreenRootState();
}

class _SelectAuthProviderScreenRootState
    extends State<SelectAuthProviderScreenRoot> {
  StreamSubscription<SelectAuthProviderEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case ShowGoogleSignInError():
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return SelectAuthProviderScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapBackButton():
              case TapSignIn():
                context.pop();
                break;
              case TapSignUpWithEmailButton():
                // 화면 연결 보기 위해 임시로 연결.
                context.go(
                  '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}',
                );
                break;
              case TapSignUpWithGoogleButton():
              case TapSignUpWithKakaoButton():
                widget.viewModel.onAction(action);
                break;
              // TODO: 각 플랫폼에 맞게 라우팅 연결할 것
              case TapSignUpWithNaverButton():
              // context.push(
              //     '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.}');
              // break;
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
