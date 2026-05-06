import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreMenuEditor extends StatelessWidget {
  final int index;
  final StoreMenu menu;
  final void Function(PartnerStoreMenuAction action) onAction;

  const PartnerStoreMenuEditor({
    super.key,
    required this.index,
    required this.menu,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.signInTextField,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '메뉴 ${index + 1}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => onAction(PartnerStoreMenuAction.removeMenu(index)),
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
              PartnerStoreMenuAction.changeMenuPrice(index: index, value: value),
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
          PartnerFormTextField(
            key: ValueKey('menu-image-$index-${menu.id ?? 'new'}'),
            hintText: '이미지 URL(선택)',
            initialValue: menu.imageUrl,
            onChanged: (value) => onAction(
              PartnerStoreMenuAction.changeMenuImageUrl(index: index, value: value),
            ),
          ),
          const SizedBox(height: 6),
          Row(
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
              Text(menu.isAvailable ? '판매 중' : '품절', style: AppTextStyles.bodySecondary),
            ],
          ),
        ],
      ),
    );
  }
}
