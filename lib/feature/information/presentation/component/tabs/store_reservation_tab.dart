import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
import 'package:capstone_2026/core/domain/model/enum/reservation_congestion_level.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/core/util/restaurant_booking_slot.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreReservationStatusTab extends StatefulWidget {
  final String category;
  final List<SalonDesigner> salonDesigners;
  final void Function() onTapReservation;
  final void Function(String designerId)? onTapSalonDesigner;
  final bool isReservationAvailable;
  final DateTime? reservationAvailabilityDate;
  final List<RestaurantTimeSlot> reservationAvailabilitySlots;
  final bool isReservationAvailabilityLoading;
  final void Function(DateTime date)? onSelectReservationDate;
  final Future<void> Function()? onPickReservationDate;
  final Map<String, dynamic> operatingHours;

  const StoreReservationStatusTab({
    super.key,
    required this.category,
    this.salonDesigners = const [],
    required this.onTapReservation,
    this.onTapSalonDesigner,
    this.isReservationAvailable = true,
    this.reservationAvailabilityDate,
    this.reservationAvailabilitySlots = const [],
    this.isReservationAvailabilityLoading = false,
    this.onSelectReservationDate,
    this.onPickReservationDate,
    this.operatingHours = const {},
  });

  @override
  State<StoreReservationStatusTab> createState() =>
      _StoreReservationStatusTabState();
}

class _StoreReservationStatusTabState extends State<StoreReservationStatusTab> {
  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final salonDesigners = widget.salonDesigners;
    final onTapReservation = widget.onTapReservation;
    final onTapSalonDesigner = widget.onTapSalonDesigner;
    final isReservationAvailable = widget.isReservationAvailable;

    if (!isReservationAvailable) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: _NotOnboardedReservationBody(),
      );
    }

    final storeCategory = StoreCategory.fromDbValue(category);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: storeCategory == StoreCategory.salon
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: ElevatedButton(
                  onPressed: onTapReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '예약/이용하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: switch (storeCategory) {
          StoreCategory.studyCafe => const _StudyCafeReservationBody(),
          StoreCategory.salon => _SalonDesignerReservationBody(
            salonDesigners: salonDesigners,
            onTapSalonDesigner: onTapSalonDesigner,
          ),
          _ => _DefaultReservationAvailabilityBody(
            selectedDate: widget.reservationAvailabilityDate ?? DateTime.now(),
            slots: widget.reservationAvailabilitySlots,
            isLoading: widget.isReservationAvailabilityLoading,
            operatingHours: widget.operatingHours,
            onSelectDate: widget.onSelectReservationDate,
            onPickDate: widget.onPickReservationDate,
          ),
        },
      ),
    );
  }
}

class _NotOnboardedReservationBody extends StatelessWidget {
  const _NotOnboardedReservationBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 36,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '아직 입점하지 않은 매장입니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 매장은 정보 조회만 가능합니다.\n예약·이용은 입점 후 이용할 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyCafeReservationBody extends StatelessWidget {
  const _StudyCafeReservationBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '현재 이용 가능한 좌석',
          showCalendarButton: false,
          onPickDate: null,
        ),
        const SizedBox(height: 24),
        const Text(
          '현재 좌석 이용 현황',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        _TimeSlotRow(
          time: '좌석 선택',
          status: '실시간 확인',
          color: AppColors.primary,
        ),
        _TimeSlotRow(
          time: '이용 시간',
          status: '2시간/4시간 등',
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _SalonDesignerReservationBody extends StatelessWidget {
  final List<SalonDesigner> salonDesigners;
  final void Function(String designerId)? onTapSalonDesigner;

  const _SalonDesignerReservationBody({
    required this.salonDesigners,
    required this.onTapSalonDesigner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '디자이너 선택',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '카드를 눌러 예약 일정을 잡을 수 있습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            letterSpacing: -0.1,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        if (salonDesigners.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              '등록된 디자이너가 없습니다. 아래 버튼으로 예약 화면으로 이동해 주세요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                letterSpacing: -0.1,
                color: Colors.grey.shade800,
              ),
            ),
          )
        else
          ...salonDesigners.map(
            (designer) {
              final void Function(String designerId)? handler =
                  onTapSalonDesigner;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SalonDesignerCard(
                  designer: designer,
                  onTap: handler == null
                      ? null
                      : () {
                          handler(designer.id);
                        },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SalonDesignerCard extends StatelessWidget {
  final SalonDesigner designer;
  final void Function()? onTap;

  const _SalonDesignerCard({required this.designer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = designer.imageUrl.trim();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color: const Color(0xFFF0F0F0),
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            },
                          )
                        : ColoredBox(
                            color: const Color(0xFFF0F0F0),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        designer.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (designer.introduction.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          designer.introduction,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            height: 1.35,
                            letterSpacing: -0.1,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultReservationAvailabilityBody extends StatelessWidget {
  final DateTime selectedDate;
  final List<RestaurantTimeSlot> slots;
  final bool isLoading;
  final Map<String, dynamic> operatingHours;
  final void Function(DateTime date)? onSelectDate;
  final Future<void> Function()? onPickDate;

  const _DefaultReservationAvailabilityBody({
    required this.selectedDate,
    required this.slots,
    required this.isLoading,
    required this.operatingHours,
    required this.onSelectDate,
    required this.onPickDate,
  });

  String _weekdayKorean(int weekday) {
    return WeekDay.values[weekday - 1].label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '방문 예정일 선택',
          showCalendarButton: onPickDate != null,
          onPickDate: onPickDate,
        ),
        const SizedBox(height: 12),
        _WeekDateStrip(
          selectedDate: selectedDate,
          operatingHours: operatingHours,
          onSelect: (date) {
            onSelectDate?.call(date);
          },
        ),
        const SizedBox(height: 24),
        Text(
          '${selectedDate.month}월 ${selectedDate.day}일 '
          '${_weekdayKorean(selectedDate.weekday)}요일 현황',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (slots.isEmpty)
          const Text(
            '예약 가능한 시간대가 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          )
        else
          ...slots.map((slot) {
            return _TimeSlotRow(
              time: slot.time,
              status: slot.congestionLevel.label,
              color: _congestionColor(slot.congestionLevel),
            );
          }),
      ],
    );
  }

  Color _congestionColor(ReservationCongestionLevel level) {
    switch (level) {
      case ReservationCongestionLevel.relaxed:
        return Colors.green;
      case ReservationCongestionLevel.normal:
        return Colors.blue;
      case ReservationCongestionLevel.busy:
        return Colors.orange;
      case ReservationCongestionLevel.saturated:
        return Colors.deepOrange;
      case ReservationCongestionLevel.closed:
        return Colors.red;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool showCalendarButton;
  final Future<void> Function()? onPickDate;

  const _SectionTitle({
    required this.title,
    required this.showCalendarButton,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        if (showCalendarButton && onPickDate != null)
          IconButton(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month, color: AppColors.primary),
          ),
      ],
    );
  }
}

class _WeekDateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Map<String, dynamic> operatingHours;
  final void Function(DateTime date) onSelect;

  const _WeekDateStrip({
    required this.selectedDate,
    required this.operatingHours,
    required this.onSelect,
  });

  String _weekdayKorean(int weekday) {
    return WeekDay.values[weekday - 1].label;
  }

  bool _isDateSelectable(DateTime date) {
    if (operatingHours.isEmpty) {
      return true;
    }

    return !RestaurantBookingSlot.isDateClosedFromOperatingHours(
      operatingHours: operatingHours,
      targetDate: date,
    );
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isSelectable = _isDateSelectable(date);

          final backgroundColor = isSelected
              ? AppColors.primary
              : isSelectable
              ? Colors.white
              : const Color(0xFFF5F5F5);
          final weekdayTextColor = isSelected
              ? Colors.white
              : isSelectable
              ? Colors.grey
              : Colors.grey.shade400;
          final dayTextColor = isSelected
              ? Colors.white
              : isSelectable
              ? Colors.black
              : Colors.grey.shade400;

          return GestureDetector(
            onTap: isSelectable ? () => onSelect(date) : null,
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayKorean(date.weekday),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: weekdayTextColor,
                      fontSize: 13,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: dayTextColor,
                      letterSpacing: -0.2,
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
}

class _TimeSlotRow extends StatelessWidget {
  final String time;
  final String status;
  final Color color;

  const _TimeSlotRow({
    required this.time,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
