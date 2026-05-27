import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationPolicySection extends StatelessWidget {
  final int reservationSlotMinutes;

  const PartnerReservationPolicySection({
    super.key,
    required this.reservationSlotMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF7F8FA),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 간격',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '현재 $reservationSlotMinutes분 간격입니다. 변경은 업장 관리 화면에서 할 수 있어요.',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
