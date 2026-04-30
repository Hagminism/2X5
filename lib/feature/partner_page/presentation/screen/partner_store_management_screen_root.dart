import 'dart:async';

import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_event.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_screen.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_view_model.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementScreenRoot extends StatefulWidget {
  final PartnerStoreManagementViewModel viewModel;

  const PartnerStoreManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreManagementScreenRoot> createState() =>
      _PartnerStoreManagementScreenRootState();
}

class _PartnerStoreManagementScreenRootState
    extends State<PartnerStoreManagementScreenRoot> {
  StreamSubscription<PartnerStoreManagementEvent>? _eventSubscription;

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStoreManagementScreen(
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
