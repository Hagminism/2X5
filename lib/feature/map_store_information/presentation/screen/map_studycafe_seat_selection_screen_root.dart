import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_action.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_screen.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_seat_selection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapStudycafeSeatSelectionScreenRoot extends StatefulWidget {
  final MapStudycafeSeatSelectionViewModel viewModel;
  final String storeId;

  const MapStudycafeSeatSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<MapStudycafeSeatSelectionScreenRoot> createState() =>
      _MapStudycafeSeatSelectionScreenRootState();
}

class _MapStudycafeSeatSelectionScreenRootState
    extends State<MapStudycafeSeatSelectionScreenRoot> {
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
        return MapStudycafeSeatSelectionScreen(
          state: widget.viewModel.state,
          onAction: (MapStudycafeSeatSelectionAction action) {
            switch (action) {
              case MapStudycafeSeatTapRetry():
              case MapStudycafeSeatTapSeat():
                widget.viewModel.onAction(action);
                break;
              case MapStudycafeSeatTapConfirmSelection(
                :final seatId,
                :final seatLabel,
              ):
                final String storeId = widget.viewModel.state.storeId;
                context.push(
                  Uri(
                    path:
                        '${Routes.map}/map-store-information/$storeId/seat/${Routes.duration}',
                    queryParameters: {
                      'storeId': storeId,
                      'seatId': seatId,
                      'seatLabel': seatLabel,
                    },
                  ).toString(),
                );
                break;
              case MapStudycafeSeatTapBack():
                context.pop();
                break;
            }
          },
        );
      },
    );
  }
}
