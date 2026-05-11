import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/partner_studycafe_layout_seat_canvas.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/partner_studycafe_layout_toolbar.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/partner_studycafe_layout_usage_option_editor.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStudyCafeLayoutScreen extends StatelessWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutScreen({
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
            title: const Text('좌석 배치 관리'),
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
                        const PartnerStudyCafeLayoutAction.tapSave(),
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
                        '스터디카페 좌석 배치',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '좌석은 드래그로 이동하고, 빈 공간 드래그로 여러 좌석을 선택할 수 있어요.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      PartnerStudyCafeLayoutToolbar(onAction: onAction),
                      const SizedBox(height: 16),
                      PartnerStudyCafeLayoutSeatCanvas(
                        state: state,
                        onAction: onAction,
                      ),
                      const SizedBox(height: 20),
                      PartnerStudyCafeLayoutUsageOptionEditor(
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
