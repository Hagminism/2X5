import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_screen_root.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutScope extends StatefulWidget {
  final PartnerStudyCafeLayoutViewModel viewModel;

  const PartnerStudyCafeLayoutScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStudyCafeLayoutScope> createState() =>
      _PartnerStudyCafeLayoutScopeState();
}

class _PartnerStudyCafeLayoutScopeState
    extends State<PartnerStudyCafeLayoutScope> {
  late final PartnerStudyCafeLayoutViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeLayoutScreenRoot(viewModel: viewModel);
  }
}
