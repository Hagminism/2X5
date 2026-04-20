import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class StoreDetailInfoSection extends StatelessWidget {
  final String storeName;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final String locationText;
  final String priceText;
  final String timeText;
  final List<String> tags;
  final void Function() onCallTap;

  const StoreDetailInfoSection({
    required this.storeName,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.locationText,
    required this.priceText,
    required this.timeText,
    required this.tags,
    required this.onCallTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating  리뷰 $reviewCount개',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onCallTap,
                icon: const Icon(Icons.phone_in_talk_outlined, size: 16),
                label: const Text('전화'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: AppTextStyles.subtitle),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.location_on_outlined, text: locationText),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.currency_bitcoin, text: priceText),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.schedule_outlined, text: timeText),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}
