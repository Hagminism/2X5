import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_screen_root.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_view_model.dart';
import 'package:flutter/material.dart';

class SignUpCustomerScope extends StatefulWidget {
  final SignUpCustomerViewModel viewModel;

  const SignUpCustomerScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<SignUpCustomerScope> createState() => _SignUpCustomerScopeState();
}

class _SignUpCustomerScopeState extends State<SignUpCustomerScope> {
  late final SignUpCustomerViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SignUpCustomerScreenRoot(viewModel: viewModel);
  }
}
