import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SearchStudycafePassSelectionSeatSummaryCard extends StatelessWidget {
  final String seatLabel;

  const SearchStudycafePassSelectionSeatSummaryCard({
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
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            '$seatLabel번 좌석',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
