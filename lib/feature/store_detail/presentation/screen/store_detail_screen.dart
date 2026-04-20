import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_bottom_bar.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_image_carousel.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_info_section.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_tab_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({
    required this.storeId,
    super.key,
  });

  final String storeId;

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
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
                    const StoreDetailImageCarousel(),
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
                            onTap: () => context.go('/home'),
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
                child: StoreDetailInfoSection(
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
                child: StoreDetailTabSection(
                  selectedTab: _selectedTab,
                  storeName: data.name, // 추가
                  location: data.location, // 추가
                  naverPlaceId: data.naverPlaceId,
                  googleSearchQuery: data.googleSearchQuery,
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
      bottomNavigationBar: StoreDetailBottomBar(
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

/* 
// [DB 연동용 주석] 실제 DB(Firestore)에서 데이터를 가져올 때 사용할 예시 모델 및 로직
class StoreModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String description;
  final String address;
  final String naverPlaceId;
  final String googleSearchQuery;

  StoreModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.address,
    required this.naverPlaceId,
    required this.googleSearchQuery,
  });

  // Firestore JSON 데이터를 객체로 변환
  factory StoreModel.fromJson(Map<String, dynamic> json, String documentId) {
    return StoreModel(
      id: documentId,
      name: json['store_name'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      naverPlaceId: json['naver_place_id'] ?? '',
      googleSearchQuery: json['google_search_query'] ?? '',
    );
  }
}
*/

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
    required this.naverPlaceId,
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
  final String naverPlaceId;
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
  naverPlaceId: '11591675',
  googleSearchQuery: '한성대학교',
);

const Map<String, _StoreDetailData> _storeData = {
  's1': _StoreDetailData(
    name: '세상의 모든 아침',
    category: '이탈리안',
    rating: 4.8,
    reviewCount: 156,
    description: '고층 뷰가 아름다운 라운지 파스타 전문점입니다.',
    location: '여의도역에서 254m',
    priceRange: '2.5 - 5만원',
    openHours: '오늘 11:10 - 21:10',
    tags: ['최대 16명 예약', '주차', '콜키지', '단체', '룸', '대관'],
    naverPlaceId: '37156328',
    googleSearchQuery: '세상의 모든 아침 여의도',
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
    naverPlaceId: '1656542083',
    googleSearchQuery: '블루보틀 여의도 카페',
  ),
  's3': _StoreDetailData(
    name: '아이디헤어 여의도점',
    category: '미용실',
    rating: 4.6,
    reviewCount: 83,
    description: '디자이너 맞춤 상담 기반 헤어/메이크업 서비스입니다.',
    location: '여의도역에서 420m',
    priceRange: '2 - 10만원',
    openHours: '오늘 10:00 - 20:00',
    tags: ['남/여 커트', '두피케어', '예약제'],
    naverPlaceId: '1056586321',
    googleSearchQuery: '아이디헤어 여의도점',
  ),
};
