import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/app_colors.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  int? selectedSeat; // 현재 사용자가 선택한 좌석 번호

  // 개별 좌석 위젯 생성 함수
  Widget _buildSeat({
    required int number,
    required double top,
    required double left,
    bool isOccupied = false,
  }) {
    final bool isSelected = selectedSeat == number;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          if (!isOccupied) {
            setState(() => selectedSeat = number);
          }
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isOccupied
                ? AppColors.authProviderButton // 이용중 (회색)
                : (isSelected ? AppColors.primary : AppColors.white), // 선택(주황) / 기본(흰색)
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          '좌석 선택',
          style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 상단 가이드 (이용가능/이용중 상태 표시)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatusInfo(AppColors.black, "이용가능"),
                const SizedBox(width: 16),
                _buildStatusInfo(AppColors.authProviderButton, "이용중"),
                const Spacer(),
                const Icon(Icons.help_outline, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 좌석 배치도 (InteractiveViewer로 줌 인/아웃 지원)
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.8,
              maxScale: 2.5,
              child: Container(
                width: 400,
                height: 650,
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    // 전체 도면 외곽선
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // --- 좌석 배치 (image_68474e.jpg 기준) ---

                    // 상단 벽면 좌석 (30, 31, 32, 33)
                    _buildSeat(number: 30, top: 40, left: 65),
                    _buildSeat(number: 31, top: 40, left: 105),
                    _buildSeat(number: 32, top: 40, left: 180),
                    _buildSeat(number: 33, top: 40, left: 220),

                    // 왼쪽 라인 (1~7번)
                    for (int i = 0; i < 4; i++)
                      _buildSeat(number: 7 - i, top: 180 + (i * 45), left: 30),
                    for (int i = 0; i < 3; i++)
                      _buildSeat(number: 3 - i, top: 400 + (i * 45), left: 30, isOccupied: i == 0),

                    // 중앙 왼쪽 라인 (14~21번)
                    for (int i = 0; i < 8; i++)
                      _buildSeat(number: 21 - i, top: 180 + (i * 45), left: 135),

                    // 중앙 오른쪽 라인 (22~29번)
                    for (int i = 0; i < 8; i++)
                      _buildSeat(number: 22 + i, top: 180 + (i * 45), left: 195),

                    // 오른쪽 라인 (8~13번)
                    for (int i = 0; i < 3; i++)
                      _buildSeat(number: 8 + i, top: 225 + (i * 45), left: 310),
                    for (int i = 0; i < 3; i++)
                      _buildSeat(number: 11 + i, top: 400 + (i * 45), left: 310),

                    // 도면 내 텍스트 가이드 (예시)
                    Positioned(top: 140, left: 135, child: Text("실내대화/촬영/취식금지", style: TextStyle(fontSize: 8, color: AppColors.danger))),
                  ],
                ),
              ),
            ),
          ),

          // 하단 선택 확인 바
          if (selectedSeat != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${selectedSeat}번 좌석", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const Text("개방형 좌석", style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                    SizedBox(
                      width: 130,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // GoRouter를 사용하여 시간 선택 화면으로 이동
                          // 라우터 설정에 맞춰 'time_selection' 또는 경로를 입력하세요.
                          context.push('/study-cafe/seats/time/$selectedSeat');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "선택",
                          style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}