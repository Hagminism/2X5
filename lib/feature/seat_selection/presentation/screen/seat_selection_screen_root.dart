import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_action.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_screen.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeatSelectionScreenRoot extends StatefulWidget {
  final SeatSelectionViewModel viewModel;
  final String storeId;

  const SeatSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SeatSelectionScreenRoot> createState() =>
      _SeatSelectionScreenRootState();
}

class _SeatSelectionScreenRootState extends State<SeatSelectionScreenRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(widget.viewModel.initialize(widget.storeId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return SeatSelectionScreen(
          state: widget.viewModel.state,
          onAction: (SeatSelectionAction action) {
            switch (action) {
              case TapRetry():
              case TapSeat():
                widget.viewModel.onAction(action);
                break;
              case TapConfirmSelection(:final seatId, :final seatLabel):
                context.push(
                  Uri(
                    path:
                        '${Routes.map}/${Routes.search}/search-store-information/${widget.viewModel.state.storeId}/seat/${Routes.duration}',
                    queryParameters: {
                      'storeId': widget.viewModel.state.storeId,
                      'seatId': seatId,
                      'seatLabel': seatLabel,
                    },
                  ).toString(),
                );
                break;
              case TapBack():
                context.pop();
                break;
            }
          },
        );
      },
    );
  }
}
