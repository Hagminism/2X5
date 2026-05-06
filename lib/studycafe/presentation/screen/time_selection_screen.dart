import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_colors.dart';

class TimeSelectionScreen extends StatefulWidget {
  final int seatNumber; // 이전 화면에서 넘겨받은 좌석 번호

  const TimeSelectionScreen({super.key, required this.seatNumber});

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  int? selectedHours; // 선택된 이용 시간 (단위: 시간)
  final List<int> timeOptions = [2, 4, 6, 8, 12]; // 이용권 옵션

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '이용 시간 선택',
          style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 선택한 좌석 요약 정보 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    "선택한 좌석: ",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  Text(
                    "${widget.seatNumber}번 좌석",
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "이용하실 시간을\n선택해주세요",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3
              ),
            ),
            const SizedBox(height: 24),

            // 시간 선택 리스트
            Expanded(
              child: ListView.builder(
                itemCount: timeOptions.length,
                itemBuilder: (context, index) {
                  final hour = timeOptions[index];
                  final bool isSelected = selectedHours == hour;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => setState(() => selectedHours = hour),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$hour시간 이용권",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 최종 예약 버튼
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedHours == null
                        ? null
                        : () {
                      // 예약 확정 로직 (Supabase API 연동 등)
                      _onReservationConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "예약 확정하기",
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onReservationConfirm() {
    // 여기에 실제 예약 로직을 넣으시면 됩니다.
    // 완료 후 홈화면이나 예약 확인 화면으로 이동
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("예약 완료"),
        content: Text("${widget.seatNumber}번 좌석 $selectedHours시간 예약되었습니다."),
        actions: [
          TextButton(
            onPressed: () => context.go('/'), // 메인 화면으로 이동
            child: const Text("확인", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}