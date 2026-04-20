class StoreDetailData {
  const StoreDetailData({
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

const defaultStoreData = StoreDetailData(
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

const Map<String, StoreDetailData> storeData = {
  's1': StoreDetailData(
    name: '돈블랑 여의도점',
    category: '고깃집',
    rating: 4.47,
    reviewCount: 280,
    description: '저온 숙성된 생한돈만을 엄선하여 제공하는 고기 맛집',
    location: '샛강역 2번 출구에서 353m',
    priceRange: '2.5 - 3.5만원',
    openHours: '오늘 11:00 - 22:00',
    tags: ['단체 이용 가능', '무선 인터넷', '콜키지'],
    naverPlaceId: '1605601457',
    googleSearchQuery: '돈블랑 여의도점',
  ),
  's2': StoreDetailData(
    name: '블루보틀 여의도 카페',
    category: '카페',
    rating: 4.7,
    reviewCount: 96,
    description: '핸드드립 원두가 유명한 조용한 스페셜티 카페입니다.',
    location: '여의도역에서 180m',
    priceRange: '0.8 - 2만원',
    openHours: '오늘 09:00 - 22:00',
    tags: ['콘센트', '와이파이', '단체석'],
    naverPlaceId: '1656542083',
    googleSearchQuery: '블루보틀 여의도 카페',
  ),
  's3': StoreDetailData(
    name: '아이디헤어 브라이튼여의도점',
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
