import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_action.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_state.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_store_section_card.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerDashboardScreen extends StatelessWidget {
  final PartnerDashboardState state;
  final void Function(PartnerDashboardAction action) onAction;

  const PartnerDashboardScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

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
                  children: [
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '대기',
                        value: _formatCount(state.todayPendingCount),
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '확정',
                        value: _formatCount(state.todayConfirmedCount),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DashboardMetricItem(
                        label: '취소',
                        value: _formatCount(state.todayCancelledCount),
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
                      onTap: () => onAction(
                        const PartnerDashboardAction.tapEditStore(),
                      ),
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
                      onPressed: () => onAction(
                        const PartnerDashboardAction.tapManageReservations(),
                      ),
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
                child: _buildNoticeEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (state.isLoading) {
      return '-';
    }

    return count.toString();
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
          if (state.isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          else
            Text(
              state.summaryMessage,
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoticeEmptyState() {
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
          child: Text(
            '현재 알림이 없습니다.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
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
