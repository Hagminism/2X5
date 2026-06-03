import 'dart:async';

import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/screen/partner_studycafe_layout_event.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/screen/partner_studycafe_layout_screen.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/screen/partner_studycafe_layout_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class PartnerStudyCafeLayoutScreenRoot extends StatefulWidget {
  final PartnerStudyCafeLayoutViewModel viewModel;

  const PartnerStudyCafeLayoutScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStudyCafeLayoutScreenRoot> createState() =>
      _PartnerStudyCafeLayoutScreenRootState();
}

class _PartnerStudyCafeLayoutScreenRootState
    extends State<PartnerStudyCafeLayoutScreenRoot> {
  StreamSubscription<PartnerStudyCafeLayoutEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case ShowMessage(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
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
        return PartnerStudyCafeLayoutScreen(
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
