import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Text(
            '선택한 날짜에는 예약 가능한 시간이 없습니다.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final selected = _sameMinute(slot.startAt, selectedStartAt);
        return OutlinedButton(
          onPressed: slot.isEnabled
              ? () {
                  onAction(SalonReservationAction.selectSlot(slot.startAt));
                }
              : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.primary
                : slot.isEnabled
                ? AppColors.white
                : AppColors.surfaceMuted,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            DateFormat('HH:mm').format(slot.startAt),
            style: AppTextStyles.label.copyWith(
              color: selected
                  ? AppColors.white
                  : slot.isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  bool _sameMinute(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}
