import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_screen_root.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_view_model.dart';
import 'package:flutter/material.dart';

class SeatSelectionScope extends StatefulWidget {
  final SeatSelectionViewModel viewModel;
  final String storeId;

  const SeatSelectionScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SeatSelectionScope> createState() => _SeatSelectionScopeState();
}

class _SeatSelectionScopeState extends State<SeatSelectionScope> {
  late final SeatSelectionViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SeatSelectionScreenRoot(
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
