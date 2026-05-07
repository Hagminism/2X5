import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_screen_root.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStoreImageScope extends StatefulWidget {
  final PartnerStoreImageViewModel viewModel;

  const PartnerStoreImageScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreImageScope> createState() => _PartnerStoreImageScopeState();
}

class _PartnerStoreImageScopeState extends State<PartnerStoreImageScope> {
  late final PartnerStoreImageViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerStoreImageScreenRoot(viewModel: viewModel);
  }
}
