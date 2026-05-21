import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SeatSelectionStatusLegend extends StatelessWidget {
  final bool showLoading;

  const SeatSelectionStatusLegend({
    super.key,
    required this.showLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatusInfo(AppColors.black, '이용가능'),
          const SizedBox(width: 16),
          _buildStatusInfo(AppColors.authProviderButton, '이용중'),
          const Spacer(),
          if (showLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
