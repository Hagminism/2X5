import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_screen_root.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_view_model.dart';
import 'package:flutter/material.dart';

class TimeSelectionScope extends StatefulWidget {
  final TimeSelectionViewModel viewModel;
  final String storeId;
  final String seatId;
  final String seatLabel;

  const TimeSelectionScope({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.seatId,
    required this.seatLabel,
  });

  @override
  State<TimeSelectionScope> createState() => _TimeSelectionScopeState();
}

class _TimeSelectionScopeState extends State<TimeSelectionScope> {
  late final TimeSelectionViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return TimeSelectionScreenRoot(
      viewModel: _viewModel,
      storeId: widget.storeId,
      seatId: widget.seatId,
      seatLabel: widget.seatLabel,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
