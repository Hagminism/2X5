import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_action.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_event.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

import 'sign_up_partner_screen.dart';

class SignUpPartnerScreenRoot extends StatefulWidget {
  final SignUpPartnerViewModel viewModel;

  const SignUpPartnerScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<SignUpPartnerScreenRoot> createState() =>
      _SignUpPartnerScreenRootState();
}

class _SignUpPartnerScreenRootState extends State<SignUpPartnerScreenRoot> {
  StreamSubscription<SignUpPartnerEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case ShowSignUpError():
            AppSnackBar.showError(context, event.message);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return SignUpPartnerScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case ChangeName():
              case ChangePhone():
              case ChangeEmail():
              case ChangePassword():
              case ChangePasswordConfirm():
              case ToggleTermsAgreement():
              case TapSubmit():
              case ChangePasswordObscureText():
              case ChangePasswordConfirmObscureText():
                widget.viewModel.onAction(action);
                break;
              case TapBackButton():
                context.go(
                  '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}',
                );
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
