import 'dart:async';

import 'package:capstone_2026/feature/reservation/presentation/component/reservation_confirm_dialog.dart';
import 'package:capstone_2026/feature/reservation/presentation/component/reservation_success_dialog.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_action.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_event.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class ReservationScreenRoot extends StatefulWidget {
  final ReservationViewModel viewModel;
  final String storeId;

  const ReservationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<ReservationScreenRoot> createState() => _ReservationScreenRootState();
}

class _ReservationScreenRootState extends State<ReservationScreenRoot> {
  StreamSubscription<ReservationEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(widget.storeId);
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case ReservationShowSnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case ReservationShowConfirmDialog():
          _showConfirmDialog(event);
          break;
        case ReservationShowSuccessDialog():
          _showSuccessDialog(event);
          break;
      }
    });
  }

  void _showConfirmDialog(ReservationShowConfirmDialog event) {
    showDialog(
      context: context,
      builder: (dialogContext) => ReservationConfirmDialog(
        bookingDate: event.bookingDate,
        bookingTime: event.bookingTime,
        guestCount: event.guestCount,
        onCancel: () {
          Navigator.pop(dialogContext);
        },
        onConfirm: () {
          Navigator.pop(dialogContext);
          widget.viewModel.onAction(const ReservationAction.confirmSubmit());
        },
      ),
    );
  }

  void _showSuccessDialog(ReservationShowSuccessDialog event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ReservationSuccessDialog(
        bookingDate: event.bookingDate,
        bookingTime: event.bookingTime,
        guestCount: event.guestCount,
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return ReservationScreen(
          state: widget.viewModel.state,
          isDaySelectable: widget.viewModel.isDaySelectable,
          canSubmit: widget.viewModel.canSubmit,
          maxGuestCount: widget.viewModel.maxGuestCount,
          onAction: (action) {
            switch (action) {
              case ReservationTapBack():
                context.pop();
                break;
              case ReservationTapRetry():
              case ReservationSelectDay():
              case ReservationSelectTime():
              case ReservationTapIncreaseGuestCount():
              case ReservationTapDecreaseGuestCount():
              case ReservationTapSubmit():
              case ReservationConfirmSubmit():
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
