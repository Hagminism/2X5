import 'package:capstone_2026/core/routing/routes.dart';
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
  State<SignUpCustomerScreenRoot> createState() => _SignUpCustomerScreenRootState();
}

class _SignUpCustomerScreenRootState extends State<SignUpCustomerScreenRoot> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return SignUpCustomerScreen(
          state: widget.viewModel.state,
          onNameChanged: widget.viewModel.onNameChanged,
          onEmailChanged: widget.viewModel.onEmailChanged,
          onPasswordChanged: widget.viewModel.onPasswordChanged,
          onPasswordConfirmChanged: widget.viewModel.onPasswordConfirmChanged,
          onTermsChanged: widget.viewModel.onTermsChanged,
          onSubmit: widget.viewModel.submitSignUp,
          onSignInTap: () => context.go(Routes.signIn),
        );
      },
    );
  }
}
