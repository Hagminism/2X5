import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class MyPageHeader extends StatelessWidget {
  const MyPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '마이페이지',
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
    );
  }
}
