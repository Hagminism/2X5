import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationsHeader extends StatelessWidget {
  const PartnerReservationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
          child: Text(
            '예약 현황',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
              fontSize: 24,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            '관리자 매장 예약을 상태별로 확인하고 처리할 수 있어요.',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
