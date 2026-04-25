import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar( // const 제거 (onTap에 함수가 들어가므로)
        title: '예약하기',
        showBackButton: true,
        onTap: () => Navigator.pop(context), // ◀ 필수 파라미터 추가 (뒤로가기 기능)
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: const Text("여기에 캘린더 위젯이 들어갑니다.", style: AppTextStyles.body),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                int time = 10 + index;
                int currentReserved = 15;
                int totalCapacity = 20;
                return _buildTimeSlotTile(time, currentReserved, totalCapacity);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: '다음 단계로',
              onTap: () { // ◀ onPressed를 onTap으로 변경 (팀 위젯 규격)
                // TODO: 다음 단계 이동 로직
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotTile(int time, int current, int total) {
    double occupancyRate = current / total;
    return ListTile(
      title: Text('$time:00', style: AppTextStyles.subtitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: occupancyRate,
            backgroundColor: AppColors.border,
            color: occupancyRate > 0.8 ? AppColors.danger : AppColors.secondary,
            minHeight: 8, // 조금 더 잘 보이게 두께 추가
          ),
          const SizedBox(height: 4),
          Text('현재 예약 $current / 총 수용 $total 명', style: AppTextStyles.caption),
        ],
      ),
      trailing: Text(
        occupancyRate >= 1.0 ? "매진" : "예약 가능",
        style: TextStyle(
          color: occupancyRate >= 1.0 ? AppColors.danger : AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}