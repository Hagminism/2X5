import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_event.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_screen.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class SalonReservationConfirmScreenRoot extends StatefulWidget {
  final SalonReservationConfirmViewModel viewModel;
  final String storeId;
  final String designerId;
  final List<String> selectedServices;
  final String selectedDateTime;

  const SalonReservationConfirmScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.designerId,
    required this.selectedServices,
    required this.selectedDateTime,
  });

  @override
  State<SalonReservationConfirmScreenRoot> createState() =>
      _SalonReservationConfirmScreenRootState();
}

class _SalonReservationConfirmScreenRootState
    extends State<SalonReservationConfirmScreenRoot> {
  StreamSubscription<SalonReservationConfirmEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;
      switch (event) {
        case PopConfirmScreen():
          context.pop();
          break;
        case ShowConfirmSnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case NavigateToHome():
          context.go(Routes.home);
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize(
        storeId: widget.storeId,
        designerId: widget.designerId,
        selectedServices: widget.selectedServices,
        selectedDateTime: widget.selectedDateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return SalonReservationConfirmScreen(
          state: widget.viewModel.state,
          onAction: widget.viewModel.onAction,
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
