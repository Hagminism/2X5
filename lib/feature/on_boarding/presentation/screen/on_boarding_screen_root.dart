import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_event.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_view_model.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class OnBoardingScreenRoot extends StatefulWidget {
  final OnBoardingViewModel viewModel;

  const OnBoardingScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<OnBoardingScreenRoot> createState() => _OnBoardingScreenRootState();
}

class _OnBoardingScreenRootState extends State<OnBoardingScreenRoot> {
  StreamSubscription<OnBoardingEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    _eventSubscription = widget.viewModel.eventStream.listen(
      (event) {
        if (mounted) {
          switch (event) {
            case ShowError():
              AppSnackBar.showError(context, event.error);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return OnBoardingScreen(
          state: widget.viewModel.state,
          onAction: (action) async {
            try {
              switch (action) {
                case TapCustomer():
                case TapPartner():
                  await widget.viewModel.onAction(action);
                  break;
              }

              if (context.mounted) {
                context.replace(Routes.home);
              }
            } catch (_) {}
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
