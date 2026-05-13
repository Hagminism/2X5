import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_screen_root.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerSalonServiceManagementScope extends StatefulWidget {
  final PartnerSalonServiceManagementViewModel viewModel;

  const PartnerSalonServiceManagementScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonServiceManagementScope> createState() =>
      _PartnerSalonServiceManagementScopeState();
}

class _PartnerSalonServiceManagementScopeState
    extends State<PartnerSalonServiceManagementScope> {
  late final PartnerSalonServiceManagementViewModel _viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerSalonServiceManagementScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
