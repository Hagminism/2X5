import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_screen_root.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStoreMenuScope extends StatefulWidget {
  final PartnerStoreMenuViewModel viewModel;

  const PartnerStoreMenuScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreMenuScope> createState() => _PartnerStoreMenuScopeState();
}

class _PartnerStoreMenuScopeState extends State<PartnerStoreMenuScope> {
  late final PartnerStoreMenuViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStoreMenuScreenRoot(viewModel: viewModel);
  }
}
