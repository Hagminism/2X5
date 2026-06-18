import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
import 'package:capstone_2026/core/presentation/screen/store_image_viewer_screen.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class InformationImageSlider extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final void Function(int) onPageChanged;
  final List<String?> images;
  final List<String> viewerImageUrls;

  const InformationImageSlider({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.images,
    required this.viewerImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final String? url = images[index];
              final Widget imageChild = Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.surfaceMuted),
                child: url != null
                    ? AppNetworkImage(url, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                      ),
              );

              if (url == null || url.trim().isEmpty || viewerImageUrls.isEmpty) {
                return imageChild;
              }

              final trimmedUrl = url.trim();
              final viewerIndex = viewerImageUrls.indexOf(trimmedUrl);

              return GestureDetector(
                onTap: () {
                  StoreImageViewerScreen.open(
                    context,
                    imageUrls: viewerImageUrls,
                    initialIndex: viewerIndex >= 0 ? viewerIndex : 0,
                  );
                },
                child: imageChild,
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPage == index
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
