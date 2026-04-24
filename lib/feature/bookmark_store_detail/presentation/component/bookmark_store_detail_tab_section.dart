import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_review_section.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class BookmarkStoreDetailTabSection extends StatelessWidget {
  const BookmarkStoreDetailTabSection({
    required this.selectedTab,
    required this.onTabSelected,
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    required this.googleSearchQuery,
    required this.reviews,
    required this.isReviewLoading,
    required this.onSubmitReview,
    required this.onTapNaverReview,
    required this.onTapGoogleReview,
    super.key,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final String storeName;
  final String location;
  final String? naverPlaceId;
  final String googleSearchQuery;
  final List<InternalReview> reviews;
  final bool isReviewLoading;
  final Future<void> Function(ReviewWriteResult result) onSubmitReview;
  final VoidCallback onTapNaverReview;
  final VoidCallback onTapGoogleReview;

  static const List<String> _tabs = ['홈', '메뉴', '사진', '리뷰', '매장정보'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (_, index) {
              final isSelected = selectedTab == index;
              return InkWell(
                onTap: () => onTabSelected(index),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: _tabView(selectedTab),
        ),
      ],
    );
  }

  Widget _tabView(int tabIndex) {
    switch (tabIndex) {
      case 3:
        return StoreDetailReviewSection(
          storeName: storeName,
          location: location,
          naverPlaceId: naverPlaceId,
          googleSearchQuery: googleSearchQuery,
          reviews: reviews,
          isReviewLoading: isReviewLoading,
          onSubmitReview: onSubmitReview,
          onTapNaverReview: onTapNaverReview,
          onTapGoogleReview: onTapGoogleReview,
        );
      case 1:
        return const Text(
          '대표 메뉴와 가격 구성을 정리한 영역이 이 위치에 표시됩니다.',
          style: _contentStyle,
        );
      case 2:
        return const Text(
          '매장 및 메뉴 사진을 갤러리 형태로 보여주는 영역입니다.',
          style: _contentStyle,
        );
      case 4:
        return const Text(
          '주소, 연락처, 운영 시간, 편의 정보가 이 탭에 정리됩니다.',
          style: _contentStyle,
        );
      case 0:
      default:
        return const Text(
          '북마크에서 진입한 상세 페이지에서도 핵심 소개와 리뷰, 외부 링크를 바로 확인할 수 있습니다.',
          style: _contentStyle,
        );
    }
  }

  static const _contentStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textPrimary,
  );
}
