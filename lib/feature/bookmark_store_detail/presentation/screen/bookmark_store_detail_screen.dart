import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_bottom_bar.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_image_carousel.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_info_section.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_tab_section.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkStoreDetailScreen extends StatefulWidget {
  const BookmarkStoreDetailScreen({
    required this.storeId,
    super.key,
  });

  final String storeId;

  @override
  State<BookmarkStoreDetailScreen> createState() =>
      _BookmarkStoreDetailScreenState();
}

class _BookmarkStoreDetailScreenState extends State<BookmarkStoreDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final data = _storeData[widget.storeId] ?? _defaultStoreData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    const BookmarkStoreDetailImageCarousel(),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 48,
                      child: Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.pop(),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.home_outlined,
                            onTap: () => context.go(Routes.home),
                          ),
                          const Spacer(),
                          _CircleIconButton(
                            icon: Icons.search_rounded,
                            onTap: () => _showSoonMessage('검색 기능은 준비 중입니다.'),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.bookmark_border_rounded,
                            onTap: () => _showSoonMessage('저장 기능은 준비 중입니다.'),
                          ),
                          const SizedBox(width: 8),
                          _CircleIconButton(
                            icon: Icons.share_outlined,
                            onTap: () => _showSoonMessage('공유 기능은 준비 중입니다.'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: BookmarkStoreDetailInfoSection(
                  storeName: data.name,
                  category: data.category,
                  rating: data.rating,
                  reviewCount: data.reviewCount,
                  description: data.description,
                  locationText: data.location,
                  priceText: data.priceRange,
                  timeText: data.openHours,
                  tags: data.tags,
                  onCallTap: () => _showSoonMessage('전화 연결 기능은 준비 중입니다.'),
                ),
              ),
              SliverToBoxAdapter(
                child: BookmarkStoreDetailTabSection(
                  selectedTab: _selectedTab,
                  storeName: data.name,
                  location: data.location,
                  naverPlaceId: data.naverPlaceId,
                  googleSearchQuery: data.googleSearchQuery,
                  onTapNaverReview: () => _openNaverReview(data),
                  onTapGoogleReview: () => _openGoogleReview(data),
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BookmarkStoreDetailBottomBar(
        onBookmarkTap: () => _showSoonMessage('저장 기능은 준비 중입니다.'),
        onCallTap: () => _showSoonMessage('전화 연결 기능은 준비 중입니다.'),
        onReserveTap: () => _showSoonMessage('예약 바텀시트는 다음 스텝에서 연결됩니다.'),
      ),
    );
  }

  void _showSoonMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openNaverReview(_StoreDetailData data) async {
    final repository = getIt<StoreReviewRepository>();
    final target = await repository.getNaverReviewLinkTarget(
      storeName: data.name,
      location: data.location,
      placeId: data.naverPlaceId,
    );

    try {
      if (target.appUri != null && await canLaunchUrl(Uri.parse('nmap://'))) {
        await launchUrl(target.appUri!, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(target.webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      _showSoonMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _openGoogleReview(_StoreDetailData data) async {
    final repository = getIt<StoreReviewRepository>();
    final uri = repository.getGoogleMapSearchUri(data.googleSearchQuery);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      _showSoonMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
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

class _StoreDetailData {
  const _StoreDetailData({
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.location,
    required this.priceRange,
    required this.openHours,
    required this.tags,
    this.naverPlaceId,
    required this.googleSearchQuery,
  });

  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final String location;
  final String priceRange;
  final String openHours;
  final List<String> tags;
  final String? naverPlaceId;
  final String googleSearchQuery;
}

const _defaultStoreData = _StoreDetailData(
  name: '업장 상세',
  category: '카테고리',
  rating: 4.5,
  reviewCount: 120,
  description: '업장 소개 텍스트입니다.',
  location: '위치 정보',
  priceRange: '가격 정보',
  openHours: '운영시간 정보',
  tags: ['주차', '단체', '룸'],
  googleSearchQuery: '한성대학교',
);

const Map<String, _StoreDetailData> _storeData = {
  's1': _StoreDetailData(
    name: '돈블랑 여의도점',
    category: '고깃집',
    rating: 4.47,
    reviewCount: 280,
    description: '저온 숙성된 생한돈만을 엄선하여 제공하는 고기 맛집',
    location: '샛강역 2번 출구에서 353m',
    priceRange: '2.5 - 3.5만원',
    openHours: '오늘 11:00 - 22:00',
    tags: ['단체 이용 가능', '무선 인터넷', '콜키지'],
    googleSearchQuery: '세상의 모든 아침 여의도',
    naverPlaceId: '1605601457',
  ),
  's2': _StoreDetailData(
    name: '블루보틀 여의도 카페',
    category: '카페',
    rating: 4.7,
    reviewCount: 96,
    description: '핸드드립 원두와 디저트가 유명한 스페셜티 카페입니다.',
    location: '여의도역에서 180m',
    priceRange: '0.8 - 2만원',
    openHours: '오늘 09:00 - 22:00',
    tags: ['콘센트', '와이파이', '단체석'],
    googleSearchQuery: '블루보틀 여의도',
    naverPlaceId: '1656542083',
  ),
  's3': _StoreDetailData(
    name: '아이디헤어 브라이튼여의도점',
    category: '미용실',
    rating: 4.6,
    reviewCount: 83,
    description: '디자이너 맞춤 상담 기반 헤어/메이크업 서비스입니다.',
    location: '여의도역에서 420m',
    priceRange: '2 - 10만원',
    openHours: '오늘 10:00 - 20:00',
    tags: ['남/여 커트', '두피케어', '예약제'],
    googleSearchQuery: '아이디헤어 여의도점',
    naverPlaceId: '1600258358',
  ),
};
