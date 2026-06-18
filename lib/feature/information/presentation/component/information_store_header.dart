import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class InformationStoreHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final double rating;
  final String? imageUrl;

  /// 입점 매장만 헤더 별점 표시. 크롤(미입점) 매장은 false.
  final bool showRating;

  const InformationStoreHeader({
    super.key,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.imageUrl,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: imageUrl != null
                  ? AppNetworkImage(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: const Icon(
                        Icons.storefront_rounded,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (showRating) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
