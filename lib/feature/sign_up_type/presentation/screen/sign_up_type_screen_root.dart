import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/screen/sign_up_type_action.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/screen/sign_up_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpTypeScreenRoot extends StatelessWidget {
  const SignUpTypeScreenRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return SignUpTypeScreen(
      onAction: (action) {
        switch (action) {
          case TapUser():
            context.go(
              '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}/${Routes.signUpCustomer}',
            );
            break;
          case TapPartner():
            context.go(
              '${Routes.signIn}/${Routes.selectAuthProvider}/${Routes.signUpType}/${Routes.signUpPartner}',
            );
            break;
          case TapBackButton():
            context.go('${Routes.signIn}/${Routes.selectAuthProvider}');
            break;
        }
      },
    );
  }
}
