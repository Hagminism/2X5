import 'dart:async';

import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_event.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_screen.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchStoreInformationScreenRoot extends StatefulWidget {
  final SearchStoreInformationViewModel viewModel;
  final String storeId;

  const SearchStoreInformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SearchStoreInformationScreenRoot> createState() =>
      _SearchStoreInformationScreenRootState();
}

class _SearchStoreInformationScreenRootState
    extends State<SearchStoreInformationScreenRoot> {
  StreamSubscription<SearchStoreInformationEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case PopSearchStoreInformationScreen():
          context.pop();
          break;
        case PushSearchStoreInformationRoute(:final location):
          context.push(location);
          break;
        case ShowSearchStoreInformationSnackBar(:final message):
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
        return SearchStoreInformationScreen(
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
