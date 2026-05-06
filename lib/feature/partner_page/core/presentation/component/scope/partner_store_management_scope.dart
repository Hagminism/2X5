import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_screen_root.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementScope extends StatefulWidget {
  final PartnerStoreManagementViewModel viewModel;

  const PartnerStoreManagementScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreManagementScope> createState() =>
      _PartnerStoreManagementScopeState();
}

class _PartnerStoreManagementScopeState
    extends State<PartnerStoreManagementScope> {
  late final PartnerStoreManagementViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStoreManagementScreenRoot(viewModel: viewModel);
  }
}
