import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_screen_root.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerSalonScheduleManagementScope extends StatefulWidget {
  final PartnerSalonScheduleManagementViewModel viewModel;

  const PartnerSalonScheduleManagementScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonScheduleManagementScope> createState() =>
      _PartnerSalonScheduleManagementScopeState();
}

class _PartnerSalonScheduleManagementScopeState
    extends State<PartnerSalonScheduleManagementScope> {
  late final PartnerSalonScheduleManagementViewModel _viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerSalonScheduleManagementScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
