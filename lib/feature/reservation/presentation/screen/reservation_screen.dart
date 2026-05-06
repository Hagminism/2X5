import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final supabase = Supabase.instance.client;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  int _guestCount = 1;
  bool _isLoading = false;

  final List<String> morningSlots = ['10:00', '10:30', '11:00', '11:30'];
  final List<String> afternoonSlots = ['13:00', '13:30', '14:00', '15:30', '16:00'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
  }

  // 수파베이스 실제 저장 로직
  Future<void> _submitReservation() async {
    setState(() => _isLoading = true);

    try {
      await supabase.from('reservations').insert({
        'booking_date': _selectedDay!.toIso8601String().split('T')[0],
        'booking_time': _selectedTime,
        'guest_count': _guestCount,
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text("예약 성공"),
          content: Text("${_selectedDay?.month}월 ${_selectedDay?.day}일 $_selectedTime\n정상적으로 예약되었습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                // 1. 다이얼로그 닫기 (다이얼로그는 Navigator 방식 유지)
                Navigator.pop(dialogContext);


                if (context.canPop()) {
                  context.pop();
                }
              },
              child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("예약 실패: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '날짜와 시간을 선택해 주세요',
        showBackButton: true,
        onTap: () {

          context.pop();
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedTime = null;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTextStyles.subtitle,
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color(0x4DFFD100),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                if (_selectedDay != null) ...[
                  _buildTimeSection("오전", morningSlots),
                  _buildTimeSection("오후", afternoonSlots),
                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildGuestCounter(),
                ] else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("날짜를 먼저 선택해 주세요.", style: AppTextStyles.body),
                  ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: PrimaryButton(
          text: _isLoading
              ? '처리 중...'
              : (_selectedTime == null ? '시간을 선택해 주세요' : '$_selectedTime 예약하기'),
          onTap: (_selectedTime == null || _isLoading)
              ? () {}
              : () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text("예약 확인"),
                content: Text(
                    "${_selectedDay?.month}월 ${_selectedDay?.day}일 $_selectedTime\n인원: $_guestCount명\n이대로 예약하시겠습니까?"
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("취소", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _submitReservation();
                    },
                    child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuestCounter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("예약 인원", style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterButton(Icons.remove, () {
                if (_guestCount > 1) setState(() => _guestCount--);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text("$_guestCount명", style: AppTextStyles.subtitle),
              ),
              _counterButton(Icons.add, () {
                setState(() => _guestCount++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Icon(icon, size: 20),
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
      onTap: () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
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