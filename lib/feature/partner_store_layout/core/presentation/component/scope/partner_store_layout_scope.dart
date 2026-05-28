import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_screen_root.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStoreLayoutScope extends StatefulWidget {
  final PartnerStoreLayoutViewModel viewModel;

  const PartnerStoreLayoutScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreLayoutScope> createState() =>
      _PartnerStoreLayoutScopeState();
}

class _PartnerStoreLayoutScopeState extends State<PartnerStoreLayoutScope> {
  late final PartnerStoreLayoutViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStoreLayoutScreenRoot(viewModel: viewModel);
  }
}
