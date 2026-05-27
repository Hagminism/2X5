import 'dart:async';

import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_action.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_event.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        case ReservationShowSnackBar():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(event.message)),
          );
          break;
        case ReservationShowSuccessDialog():
          _showSuccessDialog(event.message);
          break;
      }
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('예약 성공'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child: const Text(
              '확인',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
