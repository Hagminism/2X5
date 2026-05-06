import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreImageEditor extends StatelessWidget {
  final int index;
  final StoreImage image;
  final void Function(PartnerStoreImageAction action) onAction;

  const PartnerStoreImageEditor({
    super.key,
    required this.index,
    required this.image,
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
                  '사진 ${index + 1}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () =>
                    onAction(PartnerStoreImageAction.selectCoverImage(index)),
                child: Text(image.isCover ? '대표 사진' : '대표로 설정'),
              ),
              IconButton(
                onPressed: () =>
                    onAction(PartnerStoreImageAction.removeStoreImage(index)),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          PartnerFormTextField(
            key: ValueKey('image-url-$index-${image.id ?? 'new'}'),
            hintText: '이미지 URL',
            initialValue: image.imageUrl,
            onChanged: (value) => onAction(
              PartnerStoreImageAction.changeStoreImageUrl(
                index: index,
                value: value,
              ),
            ),
          ),
          const SizedBox(height: 8),
          PartnerFormTextField(
            key: ValueKey('image-caption-$index-${image.id ?? 'new'}'),
            hintText: '사진 설명(선택)',
            initialValue: image.caption,
            onChanged: (value) => onAction(
              PartnerStoreImageAction.changeStoreImageCaption(
                index: index,
                value: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
