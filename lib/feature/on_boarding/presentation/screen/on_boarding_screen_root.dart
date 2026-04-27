import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_view_model.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
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
        } catch (e) {
          if (!context.mounted) {
            return;
          }

          // TODO: 스낵바 디자인은 임시로 사용.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      },
    );
  }
}
