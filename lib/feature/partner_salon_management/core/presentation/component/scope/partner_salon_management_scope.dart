import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_screen_root.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerSalonManagementScope extends StatefulWidget {
  final PartnerSalonManagementViewModel viewModel;

  const PartnerSalonManagementScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonManagementScope> createState() =>
      _PartnerSalonManagementScopeState();
}

class _PartnerSalonManagementScopeState
    extends State<PartnerSalonManagementScope> {
  late final PartnerSalonManagementViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerSalonManagementScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
