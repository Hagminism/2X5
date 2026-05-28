import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen_root.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_view_model.dart';
import 'package:flutter/material.dart';

class ReservationScope extends StatefulWidget {
  final ReservationViewModel viewModel;
  final String storeId;

  const ReservationScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<ReservationScope> createState() => _ReservationScopeState();
}

class _ReservationScopeState extends State<ReservationScope> {
  late final ReservationViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return ReservationScreenRoot(
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
