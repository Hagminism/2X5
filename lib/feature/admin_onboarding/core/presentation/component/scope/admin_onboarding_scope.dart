import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_screen_root.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_view_model.dart';
import 'package:flutter/material.dart';

class AdminOnboardingScope extends StatefulWidget {
  final AdminOnboardingViewModel viewModel;

  const AdminOnboardingScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<AdminOnboardingScope> createState() => _AdminOnboardingScopeState();
}

class _AdminOnboardingScopeState extends State<AdminOnboardingScope> {
  late final AdminOnboardingViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return AdminOnboardingScreenRoot(viewModel: viewModel);
  }
}
