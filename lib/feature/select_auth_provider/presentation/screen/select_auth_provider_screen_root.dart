import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_action.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_event.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_screen.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/routing/routes.dart';

class SelectAuthProviderScreenRoot extends StatefulWidget {
  final SelectAuthProviderViewModel viewModel;
  final AppLinks appLinks;

  const SelectAuthProviderScreenRoot({
    super.key,
    required this.viewModel,
    required this.appLinks,
  });

  @override
  State<SelectAuthProviderScreenRoot> createState() =>
      _SelectAuthProviderScreenRootState();
}

class _SelectAuthProviderScreenRootState
    extends State<SelectAuthProviderScreenRoot> {
  StreamSubscription<SelectAuthProviderEvent>? _eventSubscription;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    if (_eventSubscription != null) _eventSubscription?.cancel();
    if (_linkSubscription != null) _linkSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
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
    });

    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // A) 앱이 백그라운드에 있다가 신호를 받는 경우 (Stream)
    _linkSubscription = widget.appLinks.uriLinkStream.listen((uri) {
      if (mounted) _handleDeepLink(uri);
    });

    // B) 앱이 완전히 종료되었다가 딥링크로 켜지는 경우 (Initial)
    // 네이버 로그인 후 브라우저가 앱을 새로 실행시킬 때 필수
    final initialUri = await widget.appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'team2x5') {
      final code = uri.queryParameters['code'];
      final returnedState = uri.queryParameters['state'];

      // 내가 보냈던 state와 돌아온 state가 같은지 확인
      if (code != null && returnedState == widget.viewModel.state.naverState) {
        final tokenMap = await widget.viewModel.exchangeNaverToken(
          code,
          returnedState!,
        );

        widget.viewModel.linkNaverWithFirebase(
          tokenMap['id_token'],
          tokenMap['access_token'],
        );
      }
    }
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
              case TapSignUpWithNaverButton():
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
