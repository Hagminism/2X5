import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_screen.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_view_model.dart';
import 'package:flutter/material.dart';

class StampHistoryScreenRoot extends StatefulWidget {
  const StampHistoryScreenRoot({
    required this.viewModel,
    super.key,
  });

  final StampHistoryViewModel viewModel;

  @override
  State<StampHistoryScreenRoot> createState() => _StampHistoryScreenRootState();
}

class _StampHistoryScreenRootState extends State<StampHistoryScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchStamps();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return StampHistoryScreen(state: widget.viewModel.state);
      },
    );
  }
}
