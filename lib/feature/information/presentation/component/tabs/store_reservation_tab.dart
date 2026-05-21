import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreReservationStatusTab extends StatelessWidget {
  final String category;
  final List<SalonDesigner> salonDesigners;
  final void Function() onTapReservation;
  final void Function(String designerId)? onTapSalonDesigner;

  const StoreReservationStatusTab({
    super.key,
    required this.category,
    this.salonDesigners = const [],
    required this.onTapReservation,
    this.onTapSalonDesigner,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: switch (storeCategory) {
          StoreCategory.studyCafe => const _StudyCafeReservationBody(),
          StoreCategory.salon => _SalonDesignerReservationBody(
            salonDesigners: salonDesigners,
            onTapSalonDesigner: onTapSalonDesigner,
          ),
          _ => _DefaultReservationAvailabilityBody(category: category),
        },
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
                        ? Image.network(
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

class _DefaultReservationAvailabilityBody extends StatefulWidget {
  final String category;

  const _DefaultReservationAvailabilityBody({required this.category});

  @override
  State<_DefaultReservationAvailabilityBody> createState() =>
      _DefaultReservationAvailabilityBodyState();
}

class _DefaultReservationAvailabilityBodyState
    extends State<_DefaultReservationAvailabilityBody> {
  DateTime _selectedDate = DateTime.now();

  String _weekdayKorean(int weekday) {
    return WeekDay.values[weekday - 1].label;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: '방문 예정일 선택',
          showCalendarButton: true,
          onPickDate: _pickDate,
        ),
        const SizedBox(height: 12),
        _WeekDateStrip(
          selectedDate: _selectedDate,
          onSelect: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        const SizedBox(height: 24),
        Text(
          '${_selectedDate.month}월 ${_selectedDate.day}일 ${_weekdayKorean(_selectedDate.weekday)}요일 현황',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        _TimeSlotRow(
          time: '12:00',
          status: '여유',
          color: Colors.green,
        ),
        _TimeSlotRow(
          time: '13:00',
          status: '혼잡',
          color: Colors.orange,
        ),
        _TimeSlotRow(
          time: '14:00',
          status: '마감',
          color: Colors.red,
        ),
        _TimeSlotRow(
          time: '18:00',
          status: '보통',
          color: Colors.blue,
        ),
      ],
    );
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
  final void Function(DateTime date) onSelect;

  const _WeekDateStrip({
    required this.selectedDate,
    required this.onSelect,
  });

  String _weekdayKorean(int weekday) {
    return WeekDay.values[weekday - 1].label;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => onSelect(date),
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
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
                      color: isSelected ? Colors.white : Colors.grey,
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
                      color: isSelected ? Colors.white : Colors.black,
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
