import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_screen_root.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_view_model.dart';
import 'package:flutter/material.dart';

class SalonReservationScope extends StatefulWidget {
  final SalonReservationViewModel viewModel;
  final String storeId;
  final String? initialDesignerId;

  const SalonReservationScope({
    super.key,
    required this.viewModel,
    required this.storeId,
    this.initialDesignerId,
  });

  @override
  State<SalonReservationScope> createState() => _SalonReservationScopeState();
}

class _SalonReservationScopeState extends State<SalonReservationScope> {
  late final SalonReservationViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SalonReservationScreenRoot(
      viewModel: _viewModel,
      storeId: widget.storeId,
      initialDesignerId: widget.initialDesignerId,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
