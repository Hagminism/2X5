import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class TimeSelectionSeatSummaryCard extends StatelessWidget {
  final String seatLabel;

  const TimeSelectionSeatSummaryCard({
    super.key,
    required this.seatLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '선택한 좌석: ',
            style: AppTextStyles.bodySecondary,
          ),
          Text(
            '$seatLabel번 좌석',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
