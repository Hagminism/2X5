import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class BookmarkStoreCard extends StatelessWidget {
  const BookmarkStoreCard({
    required this.name,
    required this.category,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    required this.onBookmarkTap,
    this.imageUrl,
    super.key,
  });

  final String name;
  final String category;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: _buildThumbnail(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating ($reviewCount)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onBookmarkTap,
                icon: const Icon(Icons.bookmark_rounded),
                color: AppColors.primary,
                tooltip: '저장 해제',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _thumbnailPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => _thumbnailLoading(),
      errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
    );
  }

  Widget _thumbnailPlaceholder() {
    return const ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(Icons.storefront_rounded),
      ),
    );
  }

  Widget _thumbnailLoading() {
    return const ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}