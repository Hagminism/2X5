import 'dart:async';

import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_event.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_screen.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class AddressSearchScreenRoot extends StatefulWidget {
  final AddressSearchViewModel viewModel;

  const AddressSearchScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<AddressSearchScreenRoot> createState() =>
      _AddressSearchScreenRootState();
}

class _AddressSearchScreenRootState extends State<AddressSearchScreenRoot> {
  StreamSubscription<AddressSearchEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;
      switch (event) {
        case ShowMessage(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case PopWithResult():
          debugPrint(
            '[AddressFlow] pop result address=${event.result.address}, '
            'lat=${event.result.latitude}, lng=${event.result.longitude}',
          );
          context.pop(event.result);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return AddressSearchScreen(
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
