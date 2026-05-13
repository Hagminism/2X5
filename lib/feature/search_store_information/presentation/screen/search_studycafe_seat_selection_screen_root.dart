import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_seat_selection_action.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_seat_selection_screen.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_seat_selection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchStudycafeSeatSelectionScreenRoot extends StatefulWidget {
  final SearchStudycafeSeatSelectionViewModel viewModel;
  final String storeId;

  const SearchStudycafeSeatSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SearchStudycafeSeatSelectionScreenRoot> createState() =>
      _SearchStudycafeSeatSelectionScreenRootState();
}

class _SearchStudycafeSeatSelectionScreenRootState
    extends State<SearchStudycafeSeatSelectionScreenRoot> {
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
        return SearchStudycafeSeatSelectionScreen(
          state: widget.viewModel.state,
          onAction: (SearchStudycafeSeatSelectionAction action) {
            switch (action) {
              case SearchStudycafeSeatTapRetry():
              case SearchStudycafeSeatTapSeat():
                widget.viewModel.onAction(action);
                break;
              case SearchStudycafeSeatTapConfirmSelection(
                :final seatId,
                :final seatLabel,
              ):
                final String storeId = widget.viewModel.state.storeId;
                context.push(
                  Uri(
                    path:
                        '${Routes.map}/${Routes.search}/search-store-information/$storeId/seat/${Routes.duration}',
                    queryParameters: {
                      'storeId': storeId,
                      'seatId': seatId,
                      'seatLabel': seatLabel,
                    },
                  ).toString(),
                );
                break;
              case SearchStudycafeSeatTapBack():
                context.pop();
                break;
            }
          },
        );
      },
    );
  }
}
