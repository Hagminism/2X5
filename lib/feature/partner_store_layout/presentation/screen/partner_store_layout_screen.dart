import 'package:capstone_2026/feature/partner_store_layout/presentation/component/canvas/partner_store_layout_canvas.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/component/toolbar/partner_store_layout_toolbar.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_action.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStoreLayoutScreen extends StatelessWidget {
  final PartnerStoreLayoutState state;
  final void Function(PartnerStoreLayoutAction action) onAction;

  const PartnerStoreLayoutScreen({
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
            title: const Text('내부 구조 설정'),
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
                        const PartnerStoreLayoutAction.tapSave(),
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
                        '매장 내부 구조 설정',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '테이블 및 벽, 문 등을 배치하여 매장 내부 구조를 구성해 보세요.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      PartnerStoreLayoutToolbar(onAction: onAction),
                      const SizedBox(height: 16),
                      PartnerStoreLayoutCanvas(
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
