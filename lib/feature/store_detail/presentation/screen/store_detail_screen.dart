import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_bottom_bar.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_image_carousel.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_info_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_tab_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:flutter/material.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreDetailState state;
  final void Function(StoreDetailAction) onAction;

  const StoreDetailScreen({
    required this.state,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    const StoreDetailImageCarousel(),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 48,
                      child: Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () =>
                                onAction(const StoreDetailAction.tapBack()),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.home_outlined,
                            onTap: () =>
                                onAction(const StoreDetailAction.tapHome()),
                          ),
                          const Spacer(),
                          _CircleIconButton(
                            icon: Icons.search_rounded,
                            onTap: () =>
                                onAction(const StoreDetailAction.tapSearch()),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.bookmark_border_rounded,
                            onTap: () => onAction(
                              const StoreDetailAction.tapTopBookmark(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.share_outlined,
                            onTap: () =>
                                onAction(const StoreDetailAction.tapShare()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: StoreDetailInfoSection(
                  storeName: state.data.name,
                  category: state.data.category,
                  rating: state.data.rating,
                  reviewCount: state.data.reviewCount,
                  description: state.data.description,
                  locationText: state.data.location,
                  priceText: state.data.priceRange,
                  timeText: state.data.openHours,
                  tags: state.data.tags,
                  onCallTap: () =>
                      onAction(const StoreDetailAction.tapInfoCall()),
                ),
              ),
              SliverToBoxAdapter(
                child: StoreDetailTabSection(
                  selectedTab: state.selectedTab,
                  storeName: state.data.name,
                  location: state.data.location,
                  naverPlaceId: state.data.naverPlaceId,
                  googleSearchQuery: state.data.googleSearchQuery,
                  onTabSelected: (index) {
                    onAction(StoreDetailAction.tapTab(index));
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: StoreDetailBottomBar(
        onBookmarkTap: () =>
            onAction(const StoreDetailAction.tapBottomBookmark()),
        onCallTap: () => onAction(const StoreDetailAction.tapBottomCall()),
        onReserveTap: () => onAction(const StoreDetailAction.tapReserve()),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
