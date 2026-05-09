import 'package:capstone_2026/feature/information/presentation/screen/information_screen_root.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_view_model.dart';
import 'package:flutter/material.dart';

class InformationScope extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;

  const InformationScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<InformationScope> createState() => _InformationScopeState();
}

class _InformationScopeState extends State<InformationScope> {
  late final InformationViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return InformationScreenRoot(
      viewModel: _viewModel,
      storeId: widget.storeId,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
