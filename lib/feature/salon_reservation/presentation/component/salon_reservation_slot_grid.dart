import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationSlotGrid extends StatelessWidget {
  final List<SalonReservationSlot> slots;
  final DateTime? selectedStartAt;
  final void Function(SalonReservationAction action) onAction;

  const SalonReservationSlotGrid({
    super.key,
    required this.slots,
    required this.selectedStartAt,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy, color: AppColors.textSecondary, size: 32),
            SizedBox(height: 12),
            Text(
              '선택한 날짜에는 예약 가능한 시간이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final selected = _sameUtcMinute(slot.startAt, selectedStartAt);
        return InkWell(
          onTap: slot.isEnabled
              ? () {
                  onAction(SalonReservationAction.selectSlot(slot.startAt));
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : slot.isEnabled
                      ? AppColors.white
                      : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : slot.isEnabled
                        ? AppColors.border
                        : AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Text(
              SalonBookingTime.seoulClockHHmm(slot.startAt),
              style: AppTextStyles.label.copyWith(
                color: selected
                    ? AppColors.white
                    : slot.isEnabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _sameUtcMinute(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    final ua = a.toUtc();
    final ub = b.toUtc();
    return ua.year == ub.year &&
        ua.month == ub.month &&
        ua.day == ub.day &&
        ua.hour == ub.hour &&
        ua.minute == ub.minute;
  }
}
