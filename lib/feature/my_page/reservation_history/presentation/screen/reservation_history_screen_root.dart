import 'dart:async';

import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_event.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_screen.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReservationHistoryScreenRoot extends StatefulWidget {
  const ReservationHistoryScreenRoot({
    super.key,
    required this.viewModel,
  });

  final ReservationHistoryViewModel viewModel;

  @override
  State<ReservationHistoryScreenRoot> createState() =>
      _ReservationHistoryScreenRootState();
}

class _ReservationHistoryScreenRootState
    extends State<ReservationHistoryScreenRoot> {
  StreamSubscription<ReservationHistoryEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchHistory();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }

      switch (event) {
        case PopReservationHistoryScreen():
          context.pop();
          break;
        case PushReservationHistoryRoute():
          context.push(event.location);
          break;
        case ShowReservationHistorySnackBar():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(event.message)));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return ReservationHistoryScreen(
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
