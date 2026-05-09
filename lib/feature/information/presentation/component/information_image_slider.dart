import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class InformationImageSlider extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final void Function(int) onPageChanged;
  final List<String?> images;

  const InformationImageSlider({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.images,
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
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.surfaceMuted),
                child: url != null
                    ? Image.network(url, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
