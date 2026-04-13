import 'package:app_links/app_links.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_screen_root.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_view_model.dart';
import 'package:flutter/material.dart';

class SignInScope extends StatefulWidget {
  final SignInViewModel viewModel;
  final AppLinks appLinks;

  const SignInScope({
    super.key,
    required this.viewModel,
    required this.appLinks,
  });

  @override
  State<SignInScope> createState() => _SignInScopeState();
}

class _SignInScopeState extends State<SignInScope> {
  late final SignInViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SignInScreenRoot(viewModel: viewModel, appLinks: widget.appLinks);
  }
}
