import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_screen_root.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_view_model.dart';
import 'package:flutter/material.dart';

class PartnerReservationsScope extends StatefulWidget {
  final PartnerReservationsViewModel viewModel;

  const PartnerReservationsScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerReservationsScope> createState() =>
      _PartnerReservationsScopeState();
}

class _PartnerReservationsScopeState extends State<PartnerReservationsScope> {
  late final PartnerReservationsViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerReservationsScreenRoot(viewModel: viewModel);
  }
}
