
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StorePhotoTab extends StatelessWidget {
  const StorePhotoTab({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text(
          '등록된 사진이 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final url = imageUrls[index].trim();
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url.isEmpty
              ? Container(
                  color: AppColors.surfaceMuted,
                  alignment: Alignment.center,
                  child: const Icon(Icons.hide_image_outlined),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.surfaceMuted,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
        );
      },
    );
  }
}