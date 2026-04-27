import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '회원가입',
          style: AppTextStyles.headline.copyWith(
            fontSize: 30,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '필수 정보만 입력하여 간편하게 시작하세요.',
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: const Color(0xFF5A5C5D),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
