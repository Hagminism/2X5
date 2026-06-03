import 'dart:async';

import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_event.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_screen.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_view_model.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

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
        case ShowReservationHistorySnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case ShowReservationHistoryReviewBottomSheet(
          :final storeId,
          :final storeName,
          :final reservationId,
        ):
          showModalBottomSheet<ReviewWriteResult>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => ReviewWriteBottomSheet(storeName: storeName),
          ).then((result) {
            if (result != null && mounted) {
              widget.viewModel.onAction(
                ReservationHistoryAction.submitReview(
                  storeId: storeId,
                  storeName: storeName,
                  reservationId: reservationId,
                  reviewResult: result,
                ),
              );
            }
          });
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
