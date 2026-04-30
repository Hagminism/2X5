import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.onNotificationTap, super.key});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? '사용자';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요, $userName님',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '오늘은 어떤 예약을 찾고 계신가요?',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNotificationTap,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
