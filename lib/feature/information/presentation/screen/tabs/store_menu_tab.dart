import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/util/parse_integer_price.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreMenuTab extends StatefulWidget {
  const StoreMenuTab({super.key, required this.menus});

  final List<StoreMenu> menus;

  @override
  State<StoreMenuTab> createState() => _StoreMenuTabState();
}

class _StoreMenuTabState extends State<StoreMenuTab> {
  @override
  Widget build(BuildContext context) {
    final menus = widget.menus;
    if (menus.isEmpty) {
      return const Center(
        child: Text(
          '등록된 메뉴가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      cacheExtent: 1000.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: menus.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFEEEEEE),
      ),
      itemBuilder: (context, index) {
        final menu = menus[index];
        final url = menu.imageUrl.trim();
        final desc = menu.description.trim();
        final muted = !menu.isAvailable;
        final priceLabel = resolveMenuPriceLabel(menu);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Opacity(
                  opacity: muted ? 0.45 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                            letterSpacing: -0.1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (priceLabel.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          priceLabel,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                      if (muted)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '품절',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: url.isEmpty
                      ? ColoredBox(
                          color: AppColors.surfaceMuted,
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 36,
                            color: AppColors.textSecondary.withValues(
                              alpha: muted ? 0.4 : 1,
                            ),
                          ),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          color: muted ? Colors.white : null,
                          colorBlendMode: muted ? BlendMode.saturation : null,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: AppColors.surfaceMuted,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
