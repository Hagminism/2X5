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
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          '선택한 날짜에 예약 가능한 시간이 없습니다.',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    final morning = slots.where((slot) {
      final hour = int.parse(
        SalonBookingTime.seoulClockHHmm(slot.startAt).split(':').first,
      );
      return hour < 12;
    }).toList();
    final afternoon = slots.where((slot) {
      final hour = int.parse(
        SalonBookingTime.seoulClockHHmm(slot.startAt).split(':').first,
      );
      return hour >= 12;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty)
          _buildSlotGroup(
            title: '오전',
            slots: morning,
            topPadding: 12,
            bottomPadding: morning.isNotEmpty && afternoon.isNotEmpty ? 4 : 8,
          ),
        if (afternoon.isNotEmpty)
          _buildSlotGroup(
            title: '오후',
            slots: afternoon,
            topPadding: morning.isNotEmpty ? 4 : 12,
            bottomPadding: 8,
          ),
      ],
    );
  }

  Widget _buildSlotGroup({
    required String title,
    required List<SalonReservationSlot> slots,
    required double topPadding,
    required double bottomPadding,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) {
              return _buildTimeChip(slots[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(SalonReservationSlot slot) {
    final isSelected = _sameUtcMinute(slot.startAt, selectedStartAt);
    final isEnabled = slot.isEnabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                onAction(SalonReservationAction.selectSlot(slot.startAt));
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isEnabled
                ? AppColors.white
                : AppColors.signUpWithEmailButton,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Center(
              child: Text(
                SalonBookingTime.seoulClockHHmm(slot.startAt),
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
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
