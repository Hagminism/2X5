import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_screen_root.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_view_model.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmScope extends StatelessWidget {
  final SalonReservationConfirmViewModel viewModel;
  final String storeId;
  final String designerId;
  final List<String> selectedServices;
  final String selectedDateTime;

  const SalonReservationConfirmScope({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.designerId,
    required this.selectedServices,
    required this.selectedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return SalonReservationConfirmScreenRoot(
      viewModel: viewModel,
      storeId: storeId,
      designerId: designerId,
      selectedServices: selectedServices,
      selectedDateTime: selectedDateTime,
    );
  }
}
