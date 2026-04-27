import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_view_model.dart';

import 'package:flutter/material.dart';

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
      onAction: (action) {
        switch (action) {
          case TapCustomer():
          case TapPartner():
            widget.viewModel.onAction(action);
            break;
        }
      },
    );
  }
}
