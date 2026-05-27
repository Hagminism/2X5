import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class BookmarkStoreCard extends StatelessWidget {
  const BookmarkStoreCard({
    required this.name,
    required this.category,
    required this.subtitle,
    required this.onTap,
    required this.onBookmarkTap,
    this.imageUrl,
    super.key,
  });

  final String name;
  final String category;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  static Color _categoryColor(String category) {
    switch (category) {
      case '식당':
        return const Color(0xFFFFEBEE);
      case '카페':
        return const Color(0xFFEFEBE9);
      case '스터디카페':
        return const Color(0xFFE3F2FD);
      case '미용실':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color _categoryIconColor(String category) {
    switch (category) {
      case '식당':
        return const Color(0xFFE53935);
      case '카페':
        return const Color(0xFF6D4C41);
      case '스터디카페':
        return const Color(0xFF1E88E5);
      case '미용실':
        return const Color(0xFF8E24AA);
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case '식당':
        return Icons.restaurant_rounded;
      case '카페':
        return Icons.local_cafe_rounded;
      case '스터디카페':
        return Icons.menu_book_rounded;
      case '미용실':
        return Icons.content_cut_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  static String _categoryEmoji(String category) {
    switch (category) {
      case '식당':
        return '🍽️';
      case '카페':
        return '☕';
      case '스터디카페':
        return '📚';
      case '미용실':
        return '✂';
      default:
        return '🏪';
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
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _categoryColor(category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_categoryEmoji(category)} $category',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _categoryIconColor(category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          subtitle,
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
                child: _buildCoverImage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: _categoryColor(category),
        child: Center(
          child: Icon(
            _categoryIcon(category),
            size: 48,
            color: _categoryIconColor(category),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: _categoryColor(category),
        child: Center(
          child: Icon(
            _categoryIcon(category),
            size: 48,
            color: _categoryIconColor(category),
          ),
        ),
      ),
    );
  }
}
