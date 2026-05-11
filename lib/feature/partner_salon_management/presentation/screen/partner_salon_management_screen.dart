import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerSalonManagementScreen extends StatelessWidget {
  const PartnerSalonManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('미용실 관리'),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _ManagementCard(
              icon: Icons.person_rounded,
              title: '디자이너 관리',
              description: 'salon_designers 테이블에서 디자이너 정보를 관리합니다.',
            ),
            SizedBox(height: 12),
            _ManagementCard(
              icon: Icons.spa_rounded,
              title: '시술 관리',
              description: 'salon_services 테이블에서 시술명, 소요 시간, 가격을 관리합니다.',
            ),
            SizedBox(height: 12),
            _ManagementCard(
              icon: Icons.schedule_rounded,
              title: '근무표/슬롯 관리',
              description: '30분 또는 60분 슬롯 기준으로 같은 시간대 1명만 예약을 받습니다.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
