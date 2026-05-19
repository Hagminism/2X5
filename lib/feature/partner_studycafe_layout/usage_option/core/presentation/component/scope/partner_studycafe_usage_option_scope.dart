import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_screen_root.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeUsageOptionScope extends StatefulWidget {
  final PartnerStudyCafeUsageOptionViewModel viewModel;

  const PartnerStudyCafeUsageOptionScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStudyCafeUsageOptionScope> createState() =>
      _PartnerStudyCafeUsageOptionScopeState();
}

class _PartnerStudyCafeUsageOptionScopeState
    extends State<PartnerStudyCafeUsageOptionScope> {
  late final PartnerStudyCafeUsageOptionViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeUsageOptionScreenRoot(viewModel: viewModel);
  }
}
