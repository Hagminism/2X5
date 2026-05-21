import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(now.year, now.month, now.day + 30); // 30 days ahead

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: selectedDate ?? now,
        currentDay: now,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          weekendStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: AppColors.primary),
        ),
        selectedDayPredicate: (day) {
          return isSameDay(selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          onAction(SalonReservationAction.selectDate(selectedDay));
        },
      ),
    );
  }
}
