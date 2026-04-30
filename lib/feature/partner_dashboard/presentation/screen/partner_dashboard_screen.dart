import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_store_section_card.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  '파트너 대시보드',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  '오늘 예약 흐름과 운영 현황을 빠르게 확인해 보세요.',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 20),
              PartnerStoreSectionCard(
                title: '오늘 예약 현황',
                child: Row(
                  children: const [
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '대기',
                        value: '3',
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '확정',
                        value: '12',
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '취소',
                        value: '1',
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PartnerStoreSectionCard(
                title: '빠른 작업',
                child: Column(
                  children: [
                    PrimaryButton(
                      text: '업장 정보 수정하기',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        '예약 관리 바로가기',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PartnerStoreSectionCard(
                title: '운영 알림',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNoticeRow(
                      title: '오늘 첫 예약이 10:30에 예정되어 있어요.',
                      timeText: '방금 전',
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    _buildNoticeRow(
                      title: '예약 확정 응답률이 지난주 대비 8% 상승했어요.',
                      timeText: '1시간 전',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘 운영 요약',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '오후 피크 시간(18:00~20:00) 예약이 빠르게 증가 중입니다.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeRow({required String title, required String timeText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.notifications_none_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeText,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DashboardMetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.signInTextField,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
