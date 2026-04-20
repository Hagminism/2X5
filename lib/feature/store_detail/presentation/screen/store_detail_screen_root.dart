import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_screen.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoreDetailScreenRoot extends StatefulWidget {
  final String storeId;
  final StoreDetailViewModel viewModel;

  const StoreDetailScreenRoot({
    super.key,
    required this.storeId,
    required this.viewModel,
  });

  @override
  State<StoreDetailScreenRoot> createState() => _StoreDetailScreenRootState();
}

class _StoreDetailScreenRootState extends State<StoreDetailScreenRoot> {
  StreamSubscription<StoreDetailEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    widget.viewModel.initialize(widget.storeId);

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case ShowMessage():
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(event.message)));
            break;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant StoreDetailScreenRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      widget.viewModel.initialize(widget.storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return StoreDetailScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapBack():
                context.pop();
                break;
              case TapHome():
                context.go(Routes.home);
                break;
              case TapSearch():
              case TapBookmark():
              case TapShare():
              case TapCall():
              case TapReserve():
              case MoveTab():
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
