import 'package:capstone_2026/feature/partner_store_image/presentation/component/partner_store_image_editor.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_state.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreImageScreen extends StatelessWidget {
  final PartnerStoreImageState state;
  final void Function(PartnerStoreImageAction action) onAction;

  const PartnerStoreImageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('업장 사진 관리'),
            surfaceTintColor: AppColors.white,
            backgroundColor: AppColors.white,
          ),
          backgroundColor: AppColors.white,
          body: (state.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (var i = 0; i < state.images.length; i++) ...[
                      PartnerStoreImageEditor(
                        index: i,
                        image: state.images[i],
                        localImagePath: i < state.localImagePaths.length
                            ? state.localImagePaths[i]
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
                        onPressed: () => onAction(
                          const PartnerStoreImageAction.tapAddImageFromGallery(),
                        ),
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('갤러리에서 사진 추가'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: state.isSaving ? 0.7 : 1,
                      child: IgnorePointer(
                        ignoring: state.isSaving,
                        child: PrimaryButton(
                          text: state.isSaving ? '저장 중...' : '저장',
                          onTap: () =>
                              onAction(const PartnerStoreImageAction.tapSave()),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSaving)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
