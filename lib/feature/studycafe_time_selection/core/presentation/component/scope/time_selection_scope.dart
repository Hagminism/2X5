import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_screen_root.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_view_model.dart';
import 'package:flutter/material.dart';

class TimeSelectionScope extends StatefulWidget {
  final TimeSelectionViewModel viewModel;
  final Map<String, String> seatInfo;

  const TimeSelectionScope({
    super.key,
    required this.viewModel,
    required this.seatInfo,
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
      seatInfo: widget.seatInfo,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
