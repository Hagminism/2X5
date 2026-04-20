import 'dart:async';

import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_action.dart';
import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_event.dart';
import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_screen.dart';
import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnBoardingCustomerScreenRoot extends StatefulWidget {
  final OnBoardingCustomerViewModel viewModel;

  const OnBoardingCustomerScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<OnBoardingCustomerScreenRoot> createState() =>
      _OnBoardingCustomerScreenRootState();
}

class _OnBoardingCustomerScreenRootState
    extends State<OnBoardingCustomerScreenRoot> {
  StreamSubscription<OnBoardingCustomerEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case OnBoardingCustomerEvent():
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
        return OnBoardingCustomerScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case ToggleTermsAgreement():
              case ChangeName():
              case ChangePhone():
              case ChangeEmail():
              case ChangePassword():
              case ChangePasswordConfirm():
              case ChangePasswordObscureText():
              case ChangePasswordConfirmObscureText():
              case TapSubmit():
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
