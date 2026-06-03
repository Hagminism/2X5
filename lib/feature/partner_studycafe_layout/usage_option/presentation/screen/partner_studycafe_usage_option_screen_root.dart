import 'dart:async';

import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_event.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_screen.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_view_model.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class PartnerStudyCafeUsageOptionScreenRoot extends StatefulWidget {
  final PartnerStudyCafeUsageOptionViewModel viewModel;

  const PartnerStudyCafeUsageOptionScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStudyCafeUsageOptionScreenRoot> createState() =>
      _PartnerStudyCafeUsageOptionScreenRootState();
}

class _PartnerStudyCafeUsageOptionScreenRootState
    extends State<PartnerStudyCafeUsageOptionScreenRoot> {
  StreamSubscription<PartnerStudyCafeUsageOptionEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case UsageOptionShowMessage(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStudyCafeUsageOptionScreen(
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
