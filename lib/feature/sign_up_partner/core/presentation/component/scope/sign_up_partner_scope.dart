import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_screen_root.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_view_model.dart';
import 'package:flutter/material.dart';

class SignUpPartnerScope extends StatefulWidget {
  final SignUpPartnerViewModel viewModel;

  const SignUpPartnerScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<SignUpPartnerScope> createState() => _SignUpPartnerScopeState();
}

class _SignUpPartnerScopeState extends State<SignUpPartnerScope> {
  late final SignUpPartnerViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SignUpPartnerScreenRoot(viewModel: viewModel);
  }
}
