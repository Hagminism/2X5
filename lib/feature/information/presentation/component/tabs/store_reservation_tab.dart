import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:flutter/material.dart';

class StoreReservationStatusTab extends StatefulWidget {
  final void Function() onTapReservation;
  final String category;

  const StoreReservationStatusTab({
    super.key,
    required this.category,
    required this.onTapReservation,
  });

  @override
  State<StoreReservationStatusTab> createState() =>
      _StoreReservationStatusTabState();
}

class _StoreReservationStatusTabState extends State<StoreReservationStatusTab> {
  DateTime _selectedDate = DateTime.now();

  String _getWeekdayKorean(int weekday) {
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
    final category = StoreCategory.fromDbValue(widget.category);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ElevatedButton(
            onPressed: widget.onTapReservation,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category == StoreCategory.studyCafe
                      ? '현재 이용 가능한 좌석'
                      : '방문 예정일 선택',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (category != StoreCategory.studyCafe)
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (category != StoreCategory.studyCafe) _buildDateSelector(),
            const SizedBox(height: 24),
            Text(
              category == StoreCategory.studyCafe
                  ? '현재 좌석 이용 현황'
                  : '${_selectedDate.month}월 ${_selectedDate.day}일 ${_getWeekdayKorean(_selectedDate.weekday)}요일 현황',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (category == StoreCategory.studyCafe) ...[
              _buildTimeSlot(
                time: '좌석 선택',
                status: '실시간 확인',
                color: AppColors.primary,
              ),
              _buildTimeSlot(
                time: '이용 시간',
                status: '2시간/4시간 등',
                color: Colors.blue,
              ),
            ] else if (category == StoreCategory.salon) ...[
              _buildTimeSlot(
                time: '디자이너',
                status: '선택 필요',
                color: AppColors.primary,
              ),
              _buildTimeSlot(
                time: '시술/시간',
                status: '슬롯당 1명',
                color: Colors.blue,
              ),
            ] else ...[
              _buildTimeSlot(time: '12:00', status: '여유', color: Colors.green),
              _buildTimeSlot(time: '13:00', status: '혼잡', color: Colors.orange),
              _buildTimeSlot(time: '14:00', status: '마감', color: Colors.red),
              _buildTimeSlot(time: '18:00', status: '보통', color: Colors.blue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
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
                    _getWeekdayKorean(date.weekday),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
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

  Widget _buildTimeSlot({
    required String time,
    required String status,
    required Color color,
  }) {
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
