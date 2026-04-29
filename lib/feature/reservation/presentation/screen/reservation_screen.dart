import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:table_calendar/table_calendar.dart'; // pubspec.yaml에 추가 필요
import 'package:intl/date_symbol_data_local.dart'; //한글

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null); // ◀ 한글 데이터 초기화
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime; // 선택된 시간 저장용

  // 예시 데이터 (나중에 수파베이스에서 가져올 부분)
  final List<String> morningSlots = ['10:00', '10:30', '11:00', '11:30'];
  final List<String> afternoonSlots = ['13:00', '13:30', '14:00', '15:30', '16:00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '날짜와 시간을 선택해 주세요',
        showBackButton: true,
        onTap: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 캘린더 섹션
            TableCalendar(
              locale: 'ko_KR',//한글설정
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 30)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _selectedTime = null; // 날짜 바뀌면 선택된 시간 초기화
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.subtitle,
                titleTextFormatter: (date, locale) =>
                "${date.year}년 ${date.month}월", //한글식으로
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary, // 우리 앱의 포인트 컬러
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 2. 시간 선택 섹션
            if (_selectedDay != null) ...[
              _buildTimeSection("오전", morningSlots),
              _buildTimeSection("오후", afternoonSlots),
            ] else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("날짜를 먼저 선택해 주세요.", style: AppTextStyles.body),
              ),

            const SizedBox(height: 100), // 하단 여백
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: PrimaryButton(
          text: _selectedTime == null ? '시간을 선택해 주세요' : '$_selectedTime 예약하기',
          onTap: _selectedTime == null
              ? () {} // null 대신 아무것도 안 하는 빈 함수를 넣어주세요
              : () {
            // 나중에 결제나 예약 완료 화면으로 넘어가는 로직을 여기에 넣을 겁니다!
            print('$_selectedTime 예약 버튼 클릭됨');
          },
        ),
      ),
    );
  }

  Widget _buildTimeSection(String title, List<String> slots) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((time) => _buildTimeChip(time)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    bool isSelected = _selectedTime == time;
    return GestureDetector(
    onTap: () {
    setState(() {
    _selectedTime = time;
    });
    },
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
    color: isSelected ? AppColors.primary : Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
    color: isSelected ? AppColors.primary : AppColors.border,
    ),
    ),
    child: Text(
    time,
    style: AppTextStyles.body.copyWith(
    color: isSelected ? Colors.white : Colors.black,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
    ),
    ),
    );
  }
}