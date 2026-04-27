import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/sign_up_type/presentation/component/sign_up_type_card.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatelessWidget {
  final void Function(OnBoardingAction) onAction;

  const OnBoardingScreen({
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '회원가입',
                  style: AppTextStyles.headline.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '어떤 유형으로 시작할까요?',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 24),
                SignUpTypeCard(
                  title: '일반 사용자로 시작하기',
                  description: '최소한의 정보로 빠르게 가입하고\n예약 서비스를 바로 이용할 수 있어요.',
                  icon: Icons.person_outline_rounded,
                  accentColor: const Color(0xFF2563EB),
                  onTap: () =>
                      onAction(OnBoardingAction.tapCustomer(UserType.customer)),
                ),
                const SizedBox(height: 14),
                SignUpTypeCard(
                  title: '파트너(관리자)로 시작하기',
                  description: '업장 운영에 필요한 추가 정보를 입력하고\n매장 예약 관리를 시작해요.',
                  icon: Icons.storefront_outlined,
                  accentColor: const Color(0xFF4F46E5),
                  onTap: () =>
                      onAction(OnBoardingAction.tapPartner(UserType.partner)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
