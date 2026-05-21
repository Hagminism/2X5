import 'dart:io';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerSalonDesignerEditor extends StatelessWidget {
  final int index;
  final SalonDesigner designer;
  final String? localImagePath;
  final void Function(PartnerSalonDesignerManagementAction action) onAction;

  const PartnerSalonDesignerEditor({
    super.key,
    required this.index,
    required this.designer,
    required this.localImagePath,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (localImagePath != null && localImagePath!.isNotEmpty) ||
        designer.imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '디자이너 ${index + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  onAction(
                    PartnerSalonDesignerManagementAction.tapRemoveDesigner(
                      index,
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          PartnerFormTextField(
            key: ValueKey('designer-name-$index-${designer.id}'),
            hintText: '디자이너명',
            initialValue: designer.name,
            onChanged: (value) {
              onAction(
                PartnerSalonDesignerManagementAction.changeDesignerName(
                  index: index,
                  value: value,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          PartnerFormTextField(
            key: ValueKey('designer-intro-$index-${designer.id}'),
            hintText: '소개 문구(선택)',
            initialValue: designer.introduction,
            onChanged: (value) {
              onAction(
                PartnerSalonDesignerManagementAction.changeDesignerIntroduction(
                  index: index,
                  value: value,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: AppColors.primary,
              ),
              onPressed: () {
                onAction(
                  PartnerSalonDesignerManagementAction.tapPickDesignerImage(
                    index,
                  ),
                );
              },
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                designer.imageUrl.isEmpty ? '디자이너 이미지 선택' : '이미지 변경',
              ),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: localImagePath != null && localImagePath!.isNotEmpty
                      ? Image.file(
                          File(localImagePath!),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          designer.imageUrl,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            onAction(
                              PartnerSalonDesignerManagementAction.removeDesignerImage(
                                index,
                              ),
                            );
                          },
                          child: const Text('이미지 삭제'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildActiveToggle(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  localImagePath != null && localImagePath!.isNotEmpty
                      ? '선택 완료 (저장 시 업로드)'
                      : '업로드 완료',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (!hasImage) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActiveToggle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: designer.isActive,
          activeThumbColor: AppColors.primary,
          onChanged: (value) {
            onAction(
              PartnerSalonDesignerManagementAction.toggleDesignerActive(
                index: index,
                value: value,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        Text(
          designer.isActive ? '노출 중' : '숨김',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
