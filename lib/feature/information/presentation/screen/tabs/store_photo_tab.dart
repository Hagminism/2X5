import 'package:capstone_2026/core/presentation/screen/store_image_viewer_screen.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StorePhotoTab extends StatefulWidget {
  const StorePhotoTab({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  int _validIndexForGridIndex(int gridIndex) {
    var validIndex = 0;
    for (var i = 0; i < gridIndex; i++) {
      if (imageUrls[i].trim().isNotEmpty) {
        validIndex++;
      }
    }
    return validIndex;
  }

  @override
  State<StorePhotoTab> createState() => _StorePhotoTabState();
}

class _StorePhotoTabState extends State<StorePhotoTab> {
  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text(
          '등록된 사진이 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const ClampingScrollPhysics(),
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
        final tile = ClipRRect(
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

        if (url.isEmpty) {
          return tile;
        }

        return GestureDetector(
          onTap: () => StoreImageViewerScreen.open(
            context,
            imageUrls: imageUrls,
            initialIndex: widget._validIndexForGridIndex(index),
          ),
          child: tile,
        );
      },
    );
  }
}
