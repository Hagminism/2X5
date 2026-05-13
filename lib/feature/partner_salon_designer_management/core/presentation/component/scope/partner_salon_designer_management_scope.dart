import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_screen_root.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerSalonDesignerManagementScope extends StatefulWidget {
  final PartnerSalonDesignerManagementViewModel viewModel;

  const PartnerSalonDesignerManagementScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonDesignerManagementScope> createState() =>
      _PartnerSalonDesignerManagementScopeState();
}

class _PartnerSalonDesignerManagementScopeState
    extends State<PartnerSalonDesignerManagementScope> {
  late final PartnerSalonDesignerManagementViewModel _viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerSalonDesignerManagementScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
