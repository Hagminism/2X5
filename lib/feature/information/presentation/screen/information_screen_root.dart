import 'dart:async';

import 'package:capstone_2026/core/presentation/util/share_store_text.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_event.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_screen.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class InformationScreenRoot extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;
  final int initialTabIndex;
  final bool showReviewWrite;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    this.initialTabIndex = 0,
    this.showReviewWrite = false,
  });

  @override
  State<InformationScreenRoot> createState() => _InformationScreenRootState();
}

class _InformationScreenRootState extends State<InformationScreenRoot> {
  StreamSubscription<InformationEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(
      widget.storeId,
      initialTabIndex: widget.initialTabIndex,
      showReviewWrite: widget.showReviewWrite,
    );

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case PopInformationScreen():
          context.pop();
          break;
        case PushInformationRoute():
          context.push(event.location);
          break;
        case ShowInformationSnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case ShareInformationContent(:final text, :final subject):
          shareStoreText(context, text: text, subject: subject);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return InformationScreen(
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
