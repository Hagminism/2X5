import 'dart:async';

import 'package:capstone_2026/core/routing/reservation_completion_navigation.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/component/salon_reservation_confirm_dialog.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/component/salon_reservation_success_dialog.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_action.dart';
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
      if (!mounted) {
        return;
      }
      switch (event) {
        case PopConfirmScreen():
          context.pop();
          break;
        case ShowConfirmSnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case ShowSalonConfirmDialog():
          _showConfirmDialog(event);
          break;
        case ShowSalonSuccessDialog():
          _showSuccessDialog(event);
          break;
        case NavigateToStoreDetail():
          navigateToStoreDetailAfterReservation(context);
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

  void _showConfirmDialog(ShowSalonConfirmDialog event) {
    showDialog(
      context: context,
      builder: (dialogContext) => SalonReservationConfirmDialog(
        designerName: event.designerName,
        selectedDateTime: event.selectedDateTime,
        serviceNames: event.serviceNames,
        customerRequest: event.customerRequest,
        onCancel: () {
          Navigator.pop(dialogContext);
        },
        onConfirm: () {
          Navigator.pop(dialogContext);
          widget.viewModel.onAction(
            const SalonReservationConfirmAction.confirmSubmit(),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(ShowSalonSuccessDialog event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SalonReservationSuccessDialog(
        designerName: event.designerName,
        selectedDateTime: event.selectedDateTime,
        serviceNames: event.serviceNames,
        customerRequest: event.customerRequest,
        onConfirm: () {
          Navigator.pop(dialogContext);
          navigateToStoreDetailAfterReservation(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return SalonReservationConfirmScreen(
          state: widget.viewModel.state,
          canConfirm: widget.viewModel.canConfirm,
          onAction: (action) {
            switch (action) {
              case TapConfirmBack():
                widget.viewModel.onAction(action);
                break;
              case ChangeConfirmCustomerRequest():
              case TapConfirmReservation():
              case ConfirmSubmitReservation():
                widget.viewModel.onAction(action);
                break;
            }
          },
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
