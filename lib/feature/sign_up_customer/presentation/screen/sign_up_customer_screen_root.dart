import 'dart:async';

import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_action.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_event.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sign_up_customer_screen.dart';

class SignUpCustomerScreenRoot extends StatefulWidget {
  final SignUpCustomerViewModel viewModel;

  const SignUpCustomerScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<SignUpCustomerScreenRoot> createState() =>
      _SignUpCustomerScreenRootState();
}

class _SignUpCustomerScreenRootState extends State<SignUpCustomerScreenRoot> {
  StreamSubscription<SignUpCustomerEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case SignUpCustomerEvent():
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
        return SignUpCustomerScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case ChangeName():
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
