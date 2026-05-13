import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/component/partner_salon_designer_editor.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerSalonDesignerManagementScreen extends StatelessWidget {
  final PartnerSalonDesignerManagementState state;
  final void Function(PartnerSalonDesignerManagementAction action) onAction;

  const PartnerSalonDesignerManagementScreen({
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
            title: const Text('디자이너 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                onAction(
                  const PartnerSalonDesignerManagementAction.tapBack(),
                );
              },
            ),
          ),
          body: SafeArea(child: _buildBody()),
        ),
        if (state.isLoading || state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading || state.isSaving)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildBody() {
    final errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  onAction(
                    const PartnerSalonDesignerManagementAction.tapRetry(),
                  );
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < state.designers.length; i++) ...[
          PartnerSalonDesignerEditor(
            index: i,
            designer: state.designers[i],
            localImagePath: i < state.localDesignerImagePaths.length
                ? state.localDesignerImagePaths[i]
                : null,
            onAction: onAction,
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              onAction(
                const PartnerSalonDesignerManagementAction.tapAddDesigner(),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('디자이너 추가'),
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: state.isSaving ? 0.7 : 1,
          child: IgnorePointer(
            ignoring: state.isSaving,
            child: PrimaryButton(
              text: state.isSaving ? '저장 중...' : '저장',
              onTap: () {
                onAction(
                  const PartnerSalonDesignerManagementAction.tapSaveDesigners(),
                );
              },
            ),
          ),
        ),
        if (state.saveMessage != null) ...[
          const SizedBox(height: 16),
          Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}
