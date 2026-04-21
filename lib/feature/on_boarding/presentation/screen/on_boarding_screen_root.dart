import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_screen.dart';

import 'package:flutter/material.dart';

class OnBoardingScreenRoot extends StatelessWidget {
  const OnBoardingScreenRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingScreen(
      onAction: (action) {
        switch (action) {
          case TapCustomer():
          case TapPartner():
            // TODO: 버튼 누르면 Supabase에 사용자 정보를 저장하고, 홈으로 이동하도록 연결.
            break;
        }
      },
    );
  }
}
