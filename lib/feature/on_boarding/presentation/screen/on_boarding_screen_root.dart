import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnBoardingScreenRoot extends StatelessWidget {
  const OnBoardingScreenRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
      onAction: (action) {
        switch (action) {
          case TapCustomer():
            context.go(
              '${Routes.onBoarding}/${Routes.onBoardingCustomer}',
            );
            break;
          case TapPartner():
            context.go(
              '${Routes.onBoarding}/${Routes.onBoardingPartner}',
            );
            break;
        }
      },
    );
  }
}
