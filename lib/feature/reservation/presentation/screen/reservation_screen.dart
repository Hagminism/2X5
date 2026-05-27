import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_action.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationScreen extends StatelessWidget {
  final ReservationState state;
  final void Function(ReservationAction action) onAction;
  final bool Function(DateTime day) isDaySelectable;
  final bool canSubmit;
  final int maxGuestCount;

  const ReservationScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.isDaySelectable,
    required this.canSubmit,
    required this.maxGuestCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: CustomAppBar(
            title: '날짜와 시간을 선택해 주세요',
            showBackButton: true,
            onTap: () {
              onAction(const ReservationAction.tapBack());
            },
          ),
          body: Stack(
            children: [
              if (state.loadError != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.loadError!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          onAction(const ReservationAction.tapRetry());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '다시 시도',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        locale: 'ko_KR',
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 30)),
                        focusedDay: state.focusedDay ?? DateTime.now(),
                        selectedDayPredicate: (day) =>
                            isSameDay(state.selectedDay, day),
                        enabledDayPredicate: isDaySelectable,
                        onDaySelected: (selectedDay, focusedDay) {
                          onAction(ReservationAction.selectDay(selectedDay));
                        },
                        onPageChanged: (focusedDay) {},
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: AppTextStyles.subtitle,
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: AppColors.textPrimary,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: AppTextStyles.caption,
                          weekendStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: AppTextStyles.body,
                          weekendTextStyle: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.border,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          disabledTextStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                      if (state.selectedDay != null) ...[
                        _buildTimeSection(state.slots),
                        const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                        _buildGuestCounter(state),
                      ] else
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '날짜를 먼저 선택해 주세요.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
            ],
          ),
          bottomSheet: Ink(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: PrimaryButton(
              text: _submitLabel(state),
              onTap: canSubmit && !(state.isLoading || state.isSubmitting)
                  ? () {
                      onAction(const ReservationAction.tapSubmit());
                    }
                  : () {},
            ),
          ),
        ),
        if (state.isLoading || state.isSubmitting)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading || state.isSubmitting)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  String _submitLabel(ReservationState state) {
    if (state.isSubmitting) {
      return '처리 중...';
    }
    if (state.selectedTime == null) {
      return '시간을 선택해 주세요';
    }
    return '${state.selectedTime} 예약하기';
  }

  Widget _buildGuestCounter(ReservationState state) {
    final maxGuests = maxGuestCount;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예약 인원', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            '최대 $maxGuests명까지 선택할 수 있어요.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterButton(Icons.remove, () {
                onAction(const ReservationAction.tapDecreaseGuestCount());
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${state.guestCount}명',
                  style: AppTextStyles.subtitle,
                ),
              ),
              _counterButton(Icons.add, () {
                if (state.guestCount < maxGuests) {
                  onAction(
                    const ReservationAction.tapIncreaseGuestCount(),
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(90),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(List<RestaurantTimeSlot> slots) {
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
      final hour = int.parse(slot.time.split(':').first);
      return hour < 12;
    }).toList();
    final afternoon = slots.where((slot) {
      final hour = int.parse(slot.time.split(':').first);
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
    required List<RestaurantTimeSlot> slots,
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

  Widget _buildTimeChip(RestaurantTimeSlot slot) {
    final isSelected = state.selectedTime == slot.time;
    final isEnabled = slot.isSelectable;

    return InkWell(
      onTap: isEnabled
          ? () {
              onAction(ReservationAction.selectTime(slot.time));
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
        child: Text(
          slot.time,
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
    );
  }
}
