import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StoreReviewRepositoryImpl implements StoreReviewRepository {
  StoreReviewRepositoryImpl({
    required NaverStoreSearchDataSource naverStoreSearchDataSource,
    required Supabase supabase,
  }) : _naverStoreSearchDataSource = naverStoreSearchDataSource,
       _supabase = supabase;

  final NaverStoreSearchDataSource _naverStoreSearchDataSource;
  final Supabase _supabase;

  static const String _packageName = 'com.example.capstone_2026';
  static const Uuid _uuid = Uuid();

  final Map<String, List<InternalReview>> _mockReviewsByStoreId = {
    's1': [
      InternalReview(
        id: 'mock-s1-1',
        storeId: 's1',
        userId: 'demo-user-1',
        userName: '이학민',
        storeName: '돈블랑 여의도점',
        rating: 5,
        content: '고기가 두툼하고 직원분 응대가 빨라서 회식 장소로 만족스러웠어요.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 21, 19, 20),
        visitPurpose: '모임',
      ),
      InternalReview(
        id: 'mock-s1-2',
        storeId: 's1',
        userId: 'demo-user-2',
        userName: '김세상',
        storeName: '돈블랑 여의도점',
        rating: 4,
        content: '단체 방문하기 좋고 콜키지 안내도 명확해서 편하게 이용했습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 19, 18, 10),
        visitPurpose: '가족 외식',
      ),
    ],
    's2': [
      InternalReview(
        id: 'mock-s2-1',
        storeId: 's2',
        userId: 'demo-user-3',
        userName: '백상준',
        storeName: '브루보이 여의도 카페',
        rating: 5,
        content: '좌석 간격이 여유롭고 커피 맛이 깔끔해서 작업하기 좋았습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 20, 14, 35),
        visitPurpose: '빠른 방문',
      ),
    ],
    's3': [
      InternalReview(
        id: 'mock-s3-1',
        storeId: 's3',
        userId: 'demo-user-4',
        userName: '오성민',
        storeName: '아이디헤어 브라이튼여의도점',
        rating: 5,
        content: '상담이 꼼꼼하고 원하는 스타일을 잘 잡아줘서 재방문 의사 있습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 18, 16, 50),
        visitPurpose: '데이트',
      ),
    ],
  };

  @override
  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  }) async {
    if (placeId != null && placeId.isNotEmpty) {
      return StoreReviewLinkTarget(
        appUri: Uri.parse(
          'nmap://place?id=${Uri.encodeComponent(placeId)}'
          '&appname=${Uri.encodeComponent(_packageName)}',
        ),
        webUri: Uri.parse(
          'https://m.place.naver.com/place/$placeId/review/visitor',
        ),
      );
    }

    final info = await _naverStoreSearchDataSource.fetchExactStoreInfo(
      storeName: storeName,
      location: location,
    );
    final fallbackQuery = Uri.encodeComponent('$storeName $location');
    final fallbackWebUri = Uri.parse(
      'https://m.map.naver.com/search2/search.naver?query=$fallbackQuery',
    );

    if (info == null) {
      return StoreReviewLinkTarget(webUri: fallbackWebUri);
    }

    return StoreReviewLinkTarget(
      appUri: Uri.parse(
        'nmap://search?query=${Uri.encodeComponent(info.roadAddress)}'
        '&appname=${Uri.encodeComponent(_packageName)}',
      ),
      webUri: Uri.parse(
        info.link.isNotEmpty ? info.link : fallbackWebUri.toString(),
      ),
    );
  }

  @override
  Uri getGoogleMapSearchUri(String query) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  @override
  Future<List<InternalReview>> fetchStoreReviews({
    required String storeId,
    int limit = 20,
  }) async {
    final supabaseReviews = await _fetchSupabaseStoreReviews(
      storeId: storeId,
      limit: limit,
    );
    final mockReviews = List<InternalReview>.from(
      _mockReviewsByStoreId[storeId] ?? const [],
    );

    final merged = [...mockReviews, ...supabaseReviews]..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return merged.take(limit).toList();
  }

  @override
  Future<List<InternalReview>> fetchUserReviews({
    required String userId,
    int limit = 20,
  }) async {
    final supabaseReviews = await _fetchSupabaseUserReviews(
      userId: userId,
      limit: limit,
    );
    final mockReviews = _mockReviewsByStoreId.values
        .expand((reviews) => reviews)
        .where((review) => review.userId == userId)
        .toList();

    final merged = [...mockReviews, ...supabaseReviews]..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return merged.take(limit).toList();
  }

  @override
  Future<InternalReview> submitReview({
    required String storeId,
    required String storeName,
    required String userId,
    required String userName,
    required ReviewWriteResult review,
  }) async {
    final mockReview = InternalReview(
      id: 'mock-${_uuid.v4()}',
      storeId: storeId,
      userId: userId,
      userName: userName,
      storeName: storeName,
      rating: review.rating,
      content: review.content,
      imageUrls: const [],
      createdAt: DateTime.now(),
      visitPurpose: review.visitTag,
    );

    final storeReviews = List<InternalReview>.from(
      _mockReviewsByStoreId[storeId] ?? const [],
    );
    storeReviews.insert(0, mockReview);
    _mockReviewsByStoreId[storeId] = storeReviews;

    return mockReview;
  }

  Future<List<InternalReview>> _fetchSupabaseStoreReviews({
    required String storeId,
    required int limit,
  }) async {
    try {
      final rows = await _supabase.client
          .from('reviews')
          .select(
            'id, store_id, user_id, user_name, store_name, rating, content, image_urls, created_at, visit_purpose',
          )
          .eq('store_id', storeId)
          .eq('is_visible', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] Mock mode store reviews fallback: $e');
      return const [];
    }
  }

  Future<List<InternalReview>> _fetchSupabaseUserReviews({
    required String userId,
    required int limit,
  }) async {
    try {
      final rows = await _supabase.client
          .from('reviews')
          .select(
            'id, store_id, user_id, user_name, store_name, rating, content, image_urls, created_at, visit_purpose',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] Mock mode user reviews fallback: $e');
      return const [];
    }
  }

  List<InternalReview> _mapReviewRows(dynamic rows) {
    if (rows is! List) {
      return const [];
    }

    return rows
        .whereType<Map>()
        .map((row) => InternalReview.fromSupabase(Map<String, dynamic>.from(row)))
        .toList();
  }
}
