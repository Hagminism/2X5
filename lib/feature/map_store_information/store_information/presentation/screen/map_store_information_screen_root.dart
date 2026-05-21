import 'dart:async';

import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_event.dart';
import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_screen.dart';
import 'package:capstone_2026/feature/map_store_information/store_information/presentation/screen/map_store_information_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapStoreInformationScreenRoot extends StatefulWidget {
  final MapStoreInformationViewModel viewModel;
  final String storeId;

  const MapStoreInformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<MapStoreInformationScreenRoot> createState() =>
      _MapStoreInformationScreenRootState();
}

class _MapStoreInformationScreenRootState
    extends State<MapStoreInformationScreenRoot> {
  StreamSubscription<MapStoreInformationEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case PopMapStoreInformationScreen():
          context.pop();
          break;
        case PushMapStoreInformationRoute(:final location):
          context.push(location);
          break;
        case ShowMapStoreInformationSnackBar(:final message):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return MapStoreInformationScreen(
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
