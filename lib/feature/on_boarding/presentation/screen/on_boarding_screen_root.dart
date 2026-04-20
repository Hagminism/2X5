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
          // case TapCustomer():
          //   context.push(
          //     '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}/${Routes.signUpUser}',
          //   );
          //   break;
          // case TapPartner():
          //   context.push(
          //     '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}/${Routes.signUpPartner}',
          //   );
          //   break;
          // case TapPartner():
          //   // TODO: Handle this case.
          //   throw UnimplementedError();
          case TapCustomer():
            context.go(
              '${Routes.onBoarding}/',
            );
            break;
          case TapPartner():
            context.go(
              '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}/${Routes.signUpCustomer}',
            );
            break;
        }
      },
    );
  }
}
