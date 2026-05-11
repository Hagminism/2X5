import 'package:capstone_2026/feature/partner_store_menu/presentation/component/partner_store_menu_editor.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_state.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreMenuScreen extends StatelessWidget {
  final PartnerStoreMenuState state;
  final void Function(PartnerStoreMenuAction action) onAction;

  const PartnerStoreMenuScreen({
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
            title: const Text('메뉴 관리'),
            surfaceTintColor: AppColors.white,
            backgroundColor: AppColors.white,
          ),
          backgroundColor: AppColors.white,
          body: (state.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (var i = 0; i < state.menus.length; i++) ...[
                        PartnerStoreMenuEditor(
                          index: i,
                          menu: state.menus[i],
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
                          onPressed: () =>
                              onAction(const PartnerStoreMenuAction.addMenu()),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('메뉴 추가'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: state.isSaving ? 0.7 : 1,
                        child: IgnorePointer(
                          ignoring: state.isSaving,
                          child: PrimaryButton(
                            text: state.isSaving ? '저장 중...' : '저장',
                            onTap: () => onAction(
                              const PartnerStoreMenuAction.tapSave(),
                            ),
                          ),
                        ),
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
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
