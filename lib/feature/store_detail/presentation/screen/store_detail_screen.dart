import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_bottom_bar.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_header_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_info_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_tab_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/feature/reservation/presentation/screen/reservation_screen.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreDetailState state;
  final void Function(StoreDetailAction) onAction;
  final Future<void> Function(ReviewWriteResult review) onSubmitReview;

  const StoreDetailScreen({
    required this.state,
    required this.onAction,
    required this.onSubmitReview,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: StoreDetailHeaderSection(
                    onBackTap: () {
                      onAction(const StoreDetailAction.tapBack());
                    },
                    onHomeTap: () {
                      onAction(const StoreDetailAction.tapHome());
                    },
                    onSearchTap: () {
                      onAction(const StoreDetailAction.tapSearch());
                    },
                    onBookmarkTap: () {
                      onAction(const StoreDetailAction.tapBookmark());
                    },
                    onShareTap: () {
                      onAction(const StoreDetailAction.tapShare());
                    },
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
                    onCallTap: () {
                      onAction(const StoreDetailAction.tapCall());
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: StoreDetailTabSection(
                    selectedTab: state.selectedTab,
                    storeName: state.data.name,
                    location: state.data.location,
                    naverPlaceId: state.data.naverPlaceId,
                    googleSearchQuery: state.data.googleSearchQuery,
                    reviews: state.reviews,
                    isReviewLoading: state.isReviewLoading,
                    naverMenus: state.naverMenus,
                    naverReviews: state.naverReviews,
                    isNaverDataLoading: state.isNaverDataLoading,
                    stampStatus: state.stampStatus,
                    onSubmitReview: onSubmitReview,
                    onTapNaverReview: () {
                      onAction(const StoreDetailAction.tapNaverReviewButton());
                    },
                    onTapGoogleReview: () {
                      onAction(const StoreDetailAction.tapGoogleReviewButton());
                    },
                    onTabSelected: (index) {
                      onAction(StoreDetailAction.moveTab(index));
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: StoreDetailBottomBar(
        onBookmarkTap: () {
          onAction(const StoreDetailAction.tapBookmark());
        },
        onCallTap: () {
          onAction(const StoreDetailAction.tapCall());
        },
        onReserveTap: () {
          //onAction(const StoreDetailAction.tapReserve());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReservationScreen()),
          ); //예약 누르면 예약 페이지로 넘어감
        },
      ),
    );
  }
}
