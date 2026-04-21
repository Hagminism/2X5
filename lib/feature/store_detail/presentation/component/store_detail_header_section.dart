import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_image_carousel.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_top_action_bar.dart';
import 'package:flutter/material.dart';

class StoreDetailHeaderSection extends StatelessWidget {
  final void Function() onBackTap;
  final void Function() onHomeTap;
  final void Function() onSearchTap;
  final void Function() onBookmarkTap;
  final void Function() onShareTap;

  const StoreDetailHeaderSection({
    super.key,
    required this.onBackTap,
    required this.onHomeTap,
    required this.onSearchTap,
    required this.onBookmarkTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const StoreDetailImageCarousel(),
        StoreDetailTopActionBar(
          onBackTap: onBackTap,
          onHomeTap: onHomeTap,
          onSearchTap: onSearchTap,
          onBookmarkTap: onBookmarkTap,
          onShareTap: onShareTap,
        ),
      ],
    );
  }
}
