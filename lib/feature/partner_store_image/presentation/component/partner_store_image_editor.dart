import 'dart:io';

import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreImageEditor extends StatelessWidget {
  final int index;
  final StoreImage image;
  final String? localImagePath;
  final void Function(PartnerStoreImageAction action) onAction;

  const PartnerStoreImageEditor({
    super.key,
    required this.index,
    required this.image,
    required this.localImagePath,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
                  '사진 ${index + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
          if ((localImagePath != null && localImagePath!.isNotEmpty) ||
              image.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: localImagePath != null && localImagePath!.isNotEmpty
                  ? Image.file(
                      File(localImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
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
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
