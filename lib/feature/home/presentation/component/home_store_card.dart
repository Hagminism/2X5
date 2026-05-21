import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class HomeStoreCard extends StatelessWidget {
  const HomeStoreCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.category,
    required this.onTap,
    required this.onBookmarkTap,
    required this.isBookmarked,
    this.imageUrl,
    super.key,
  });

  final String name;
  final String subtitle;
  final double rating;
  final String category;
  final String? imageUrl;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  static Color _categoryColor(String category) {
    switch (category) {
      case 'restaurant':
        return const Color(0xFFFFEBEE);
      case 'cafe':
        return const Color(0xFFEFEBE9);
      case 'study_cafe':
        return const Color(0xFFE3F2FD);
      case 'salon':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color _categoryIconColor(String category) {
    switch (category) {
      case 'restaurant':
        return const Color(0xFFE53935);
      case 'cafe':
        return const Color(0xFF6D4C41);
      case 'study_cafe':
        return const Color(0xFF1E88E5);
      case 'salon':
        return const Color(0xFF8E24AA);
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'study_cafe':
        return Icons.menu_book_rounded;
      case 'salon':
        return Icons.content_cut_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onBookmarkTap,
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: isBookmarked
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ' · $subtitle',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: _categoryColor(category),
                        child: Center(
                          child: Icon(
                            _categoryIcon(category),
                            size: 48,
                            color: _categoryIconColor(category),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}