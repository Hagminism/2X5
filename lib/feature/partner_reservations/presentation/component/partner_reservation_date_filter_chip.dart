import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationDateFilterChip extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function() onTapDateFilter;
  final void Function() onClearDate;
  final String Function(DateTime) formatDate;

  const PartnerReservationDateFilterChip({
    super.key,
    required this.selectedDate,
    required this.onTapDateFilter,
    required this.onClearDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDate != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDateFilter,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                isSelected ? formatDate(selectedDate!) : '날짜 선택',
                style: AppTextStyles.label.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onClearDate,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
