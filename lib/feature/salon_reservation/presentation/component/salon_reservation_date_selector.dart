import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalonReservationDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(SalonReservationAction action) onAction;

  const SalonReservationDateSelector({
    super.key,
    required this.selectedDate,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(
      14,
      (index) => DateTime(today.year, today.month, today.day + index),
    );
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _sameDate(date, selectedDate);
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              onAction(SalonReservationAction.selectDate(date));
            },
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'ko_KR').format(date),
                    style: AppTextStyles.caption.copyWith(
                      color: selected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: AppTextStyles.body.copyWith(
                      color: selected ? AppColors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _sameDate(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
