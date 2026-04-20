import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_circle_icon_button.dart';
import 'package:flutter/material.dart';

class StoreDetailTopActionBar extends StatelessWidget {
  final void Function() onBackTap;
  final void Function() onHomeTap;
  final void Function() onSearchTap;
  final void Function() onBookmarkTap;
  final void Function() onShareTap;

  const StoreDetailTopActionBar({
    super.key,
    required this.onBackTap,
    required this.onHomeTap,
    required this.onSearchTap,
    required this.onBookmarkTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      top: 48,
      child: Row(
        children: [
          StoreDetailCircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBackTap,
          ),
          const SizedBox(width: 8),
          StoreDetailCircleIconButton(
            icon: Icons.home_outlined,
            onTap: onHomeTap,
          ),
          const Spacer(),
          StoreDetailCircleIconButton(
            icon: Icons.search_rounded,
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),
          StoreDetailCircleIconButton(
            icon: Icons.bookmark_border_rounded,
            onTap: onBookmarkTap,
          ),
          const SizedBox(width: 8),
          StoreDetailCircleIconButton(
            icon: Icons.share_outlined,
            onTap: onShareTap,
          ),
        ],
      ),
    );
  }
}
