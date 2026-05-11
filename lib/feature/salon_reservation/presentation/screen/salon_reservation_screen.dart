import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalonReservationScreen extends StatelessWidget {
  final String storeId;

  const SalonReservationScreen({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: '미용실 예약',
        showBackButton: true,
        onTap: () => context.pop(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '디자이너와 시술을 선택해 주세요',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '미용실은 매장별 예약 슬롯 단위에 따라 같은 시간대에 1명만 예약할 수 있어요.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              _ComingSoonCard(storeId: storeId),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String storeId;

  const _ComingSoonCard({
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '매장 ID: $storeId\n디자이너, 시술, 시간 선택 화면을 연결할 예정입니다.',
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
