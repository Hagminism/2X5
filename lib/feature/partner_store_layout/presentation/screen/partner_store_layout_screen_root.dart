import 'dart:async';

import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_event.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_screen.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStoreLayoutScreenRoot extends StatefulWidget {
  final PartnerStoreLayoutViewModel viewModel;

  const PartnerStoreLayoutScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreLayoutScreenRoot> createState() =>
      _PartnerStoreLayoutScreenRootState();
}

class _PartnerStoreLayoutScreenRootState
    extends State<PartnerStoreLayoutScreenRoot> {
  StreamSubscription<PartnerStoreLayoutEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;

      switch (event) {
        case ShowMessage():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              duration: const Duration(milliseconds: 1400),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case Pop():
          context.pop();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStoreLayoutScreen(
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
