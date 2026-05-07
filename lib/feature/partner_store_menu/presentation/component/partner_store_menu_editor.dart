import 'dart:io';

import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreMenuEditor extends StatelessWidget {
  final int index;
  final StoreMenu menu;
  final String? localImagePath;
  final void Function(PartnerStoreMenuAction action) onAction;

  const PartnerStoreMenuEditor({
    super.key,
    required this.index,
    required this.menu,
    required this.localImagePath,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (localImagePath != null && localImagePath!.isNotEmpty) ||
        menu.imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                  '메뉴 ${index + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    onAction(PartnerStoreMenuAction.removeMenu(index)),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          PartnerFormTextField(
            key: ValueKey('menu-name-$index-${menu.id ?? 'new'}'),
            hintText: '메뉴명',
            initialValue: menu.name,
            onChanged: (value) => onAction(
              PartnerStoreMenuAction.changeMenuName(index: index, value: value),
            ),
          ),
          const SizedBox(height: 8),
          PartnerFormTextField(
            key: ValueKey('menu-price-$index-${menu.id ?? 'new'}'),
            hintText: '가격(원)',
            keyboardType: TextInputType.number,
            initialValue: menu.price.toString(),
            onChanged: (value) => onAction(
              PartnerStoreMenuAction.changeMenuPrice(
                index: index,
                value: value,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PartnerFormTextField(
            key: ValueKey('menu-desc-$index-${menu.id ?? 'new'}'),
            hintText: '설명(선택)',
            initialValue: menu.description,
            onChanged: (value) => onAction(
              PartnerStoreMenuAction.changeMenuDescription(
                index: index,
                value: value,
              ),
            ),
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
              onPressed: () =>
                  onAction(PartnerStoreMenuAction.tapPickMenuImage(index)),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                menu.imageUrl.isEmpty ? '메뉴 이미지 선택' : '이미지 변경',
              ),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 6),
          ],
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
                          menu.imageUrl,
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
                          onPressed: () => onAction(
                            PartnerStoreMenuAction.removeMenuImage(index),
                          ),
                          child: const Text('이미지 삭제'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildAvailabilityToggle(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
              child: _buildAvailabilityToggle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: menu.isAvailable,
          activeThumbColor: AppColors.primary,
          onChanged: (value) => onAction(
            PartnerStoreMenuAction.toggleMenuAvailable(
              index: index,
              value: value,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          menu.isAvailable ? '판매 중' : '품절',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
