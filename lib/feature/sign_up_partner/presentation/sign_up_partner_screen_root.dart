import 'dart:async';

import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_action.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_event.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          case SignUpPartnerEvent():
            // TODO: 스낵바 디자인은 기본 디자인으로 임시 사용
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(event.message),
                duration: Duration(milliseconds: 1500),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
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
              case ChangeBusinessNumber():
              case ToggleTermsAgreement():
              case TapSubmit():
              case ChangePasswordObscureText():
              case ChangePasswordConfirmObscureText():
                widget.viewModel.onAction(action);
                break;
              case TapBackButton():
                context.pop();
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
