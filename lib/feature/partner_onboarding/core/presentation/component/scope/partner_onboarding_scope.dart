import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_screen_root.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_view_model.dart';
import 'package:flutter/material.dart';

class PartnerOnboardingScope extends StatefulWidget {
  final PartnerOnboardingViewModel viewModel;

  const PartnerOnboardingScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerOnboardingScope> createState() => _PartnerOnboardingScopeState();
}

class _PartnerOnboardingScopeState extends State<PartnerOnboardingScope> {
  late final PartnerOnboardingViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerOnboardingScreenRoot(viewModel: viewModel);
  }
}
