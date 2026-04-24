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
          reviews: const [],
          isReviewLoading: false,
          onTapNaverReview: onTapNaverReview,
          onTapGoogleReview: onTapGoogleReview,
        );
      case 1:
        return const Text(
          '대표 메뉴, 가격, 구성 정보를 이 영역에 표시합니다.',
          style: _contentStyle,
        );
      case 2:
        return const Text('업장/메뉴 사진 목록을 갤러리 형태로 표시합니다.', style: _contentStyle);
      case 4:
        return const Text(
          '매장 주소, 운영시간, 주차/편의 정보 등 상세 정보를 표시합니다.',
          style: _contentStyle,
        );
      case 0:
      default:
        return const Text(
          '업장 소개, 추천 포인트, 공지사항 등 핵심 정보를 우선 제공합니다.',
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
