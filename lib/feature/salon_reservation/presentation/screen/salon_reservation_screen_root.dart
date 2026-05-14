import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_screen.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_view_model.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalonReservationScreenRoot extends StatefulWidget {
  final SalonReservationViewModel viewModel;
  final String storeId;
  final String? initialDesignerId;

  const SalonReservationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    this.initialDesignerId,
  });

  @override
  State<SalonReservationScreenRoot> createState() =>
      _SalonReservationScreenRootState();
}

class _SalonReservationScreenRootState
    extends State<SalonReservationScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(
      widget.storeId,
      initialDesignerId: widget.initialDesignerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return SalonReservationScreen(
          state: widget.viewModel.state,
          canSubmit: widget.viewModel.canSubmit,
          onAction: (SalonReservationAction action) {
            switch (action) {
              case SalonReservationTapRetry():
              case SalonReservationSelectDesigner():
              case SalonReservationSelectService():
              case SalonReservationSelectDate():
              case SalonReservationSelectSlot():
                widget.viewModel.onAction(action);
                break;
              case SalonReservationTapBack():
                context.pop();
                break;
              case SalonReservationTapSubmit():
                _onTapSubmit();
                break;
            }
          },
        );
      },
    );
  }

  void _onTapSubmit() {
    if (!widget.viewModel.canSubmit) {
      return;
    }

    final designer = widget.viewModel.selectedDesigner();
    final services = widget.viewModel.selectedServices();
    final startAt = widget.viewModel.state.selectedStartAt;
    if (designer == null || services.isEmpty || startAt == null) {
      return;
    }

    final currentUri = GoRouterState.of(context).uri;
    final newUri = currentUri.replace(
      path: '${currentUri.path}/${Routes.salonReservationConfirm}',
      queryParameters: {
        'designerId': designer.id,
        'selectedServices': services.map((s) => s.id).toList(),
        'selectedDateTime': startAt.toUtc().toIso8601String(),
      },
    );

    context.push(newUri.toString());
  }
}
