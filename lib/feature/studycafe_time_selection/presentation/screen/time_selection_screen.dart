import 'package:capstone_2026/feature/studycafe_time_selection/presentation/component/time_selection_seat_summary_card.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/component/time_selection_submit_bar.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/component/time_selection_usage_option_list.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_action.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class TimeSelectionScreen extends StatelessWidget {
  final TimeSelectionState state;
  final bool canSubmit;
  final void Function(TimeSelectionAction action) onAction;

  const TimeSelectionScreen({
    super.key,
    required this.state,
    required this.canSubmit,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            surfaceTintColor: AppColors.white,
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: AppColors.textPrimary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () {
                onAction(const TimeSelectionAction.tapBack());
              },
            ),
            title: Text(
              '이용권 선택',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TimeSelectionSeatSummaryCard(seatLabel: state.seatLabel),
                if (state.seatTakenByOther) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.authProviderButton.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '이 좌석은 다른 사용자가 먼저 이용 중입니다. 뒤로 가서 다른 좌석을 선택해 주세요.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  _headlineText(),
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildContent(context),
                ),
                TimeSelectionSubmitBar(
                  enabled: canSubmit,
                  isSubmitting: state.isSubmitting,
                  onAction: onAction,
                ),
              ],
            ),
          ),
        ),
        if (state.isSubmitting)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSubmitting)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  String _headlineText() {
    if (state.isLoadingDetail) {
      return '이용권 정보를\n불러오는 중입니다';
    }
    if (state.loadError != null) {
      return '이용권을 불러오지\n못했습니다';
    }
    if (state.usageOptions.isEmpty) {
      return '이용 가능한\n이용권이 없습니다';
    }
    return '이용하실 시간을\n선택해주세요';
  }

  Widget _buildContent(BuildContext context) {
    if (state.isLoadingDetail) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.loadError!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                onAction(const TimeSelectionAction.tapRetry());
              },
              child: Text(
                '다시 시도',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (state.usageOptions.isEmpty) {
      return Center(
        child: Text(
          '매장에 등록된 이용권이 없습니다.',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }
    return TimeSelectionUsageOptionList(
      options: state.usageOptions,
      selectedDurationMinutes: state.selectedDurationMinutes,
      onAction: onAction,
    );
  }
}
