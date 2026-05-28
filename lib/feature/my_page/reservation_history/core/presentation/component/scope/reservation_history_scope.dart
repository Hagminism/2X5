import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_screen_root.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_view_model.dart';
import 'package:flutter/material.dart';

class ReservationHistoryScope extends StatefulWidget {
  const ReservationHistoryScope({
    super.key,
    required this.viewModel,
  });

  final ReservationHistoryViewModel viewModel;

  @override
  State<ReservationHistoryScope> createState() =>
      _ReservationHistoryScopeState();
}

class _ReservationHistoryScopeState extends State<ReservationHistoryScope> {
  late final ReservationHistoryViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return ReservationHistoryScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
