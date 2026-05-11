import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/usage_option/partner_studycafe_layout_usage_option_editor.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_usage_option_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_usage_option_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStudyCafeUsageOptionScreen extends StatelessWidget {
  final PartnerStudyCafeUsageOptionState state;
  final void Function(PartnerStudyCafeUsageOptionAction action) onAction;

  const PartnerStudyCafeUsageOptionScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: const Text('이용권 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              TextButton(
                onPressed: state.isSaving
                    ? null
                    : () => onAction(
                          const PartnerStudyCafeUsageOptionAction.tapSave(),
                        ),
                child: const Text('저장'),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '이용권 설정',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '이용 시간·가격·판매 여부를 설정하면 예약 화면에 반영돼요.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 20),
                      PartnerStudyCafeUsageOptionEditor(
                        state: state,
                        onAction: onAction,
                      ),
                    ],
                  ),
                ),
        ),
        if (state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSaving)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}
