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
    required SupabaseClient supabase,
  }) : _naverStoreSearchDataSource = naverStoreSearchDataSource,
       _supabase = supabase;

  final NaverStoreSearchDataSource _naverStoreSearchDataSource;
  final SupabaseClient _supabase;

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
        content: '고기 맛집이에요. 반찬도 잘 나오고 고기 육즙도 좋아서 만족스러운 식사였습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 21, 19, 20),
        visitPurpose: '모임',
      ),
      InternalReview(
        id: 'mock-s1-2',
        storeId: 's1',
        userId: 'demo-user-2',
        userName: '김민상',
        storeName: '돈블랑 여의도점',
        rating: 5,
        content: '고기와 반찬이 다 맛있고 된장고추, 양배추, 무말랭이, 백김치까지 구성도 좋아요.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 20, 18, 10),
        visitPurpose: '가족 외식',
      ),
      InternalReview(
        id: 'mock-s1-3',
        storeId: 's1',
        userId: 'demo-user-3',
        userName: '백상준',
        storeName: '돈블랑 여의도점',
        rating: 5,
        content: '신선한 고기를 맛있게 구워주셔서 가족 생일 때마다 방문하고 있어요. 와인 콜키지도 좋았습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 19, 19, 40),
        visitPurpose: '가족 외식',
      ),
      InternalReview(
        id: 'mock-s1-4',
        storeId: 's1',
        userId: 'demo-user-4',
        userName: '오성민',
        storeName: '돈블랑 여의도점',
        rating: 5,
        content: '창가 자리 분위기가 좋고 직원분들이 맛있게 구워주셔서 친구들과 만족스러운 한 끼였어요.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 18, 20, 5),
        visitPurpose: '친구 모임',
      ),
      InternalReview(
        id: 'mock-s1-5',
        storeId: 's1',
        userId: 'demo-user-5',
        userName: '김동현',
        storeName: '돈블랑 여의도점',
        rating: 5,
        content: '회식이나 모임으로 가기 좋고 쌈 종류도 다양해서 여러 명이 방문해도 만족도가 높습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 17, 18, 30),
        visitPurpose: '회식',
      ),
    ],
    's2': [
      InternalReview(
        id: 'mock-s2-1',
        storeId: 's2',
        userId: 'demo-user-6',
        userName: '박상준',
        storeName: '블루보틀 여의도 카페',
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
        userId: 'demo-user-7',
        userName: '오세상',
        storeName: '아이디헤어 브라이튼여의도점',
        rating: 5,
        content: '상담이 꼼꼼하고 원하는 스타일을 잘 잡아줘서 재방문 의사가 있습니다.',
        imageUrls: const [],
        createdAt: DateTime(2026, 4, 18, 16, 50),
        visitPurpose: '빠른 방문',
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

    final merged = [...mockReviews, ...supabaseReviews]
      ..sort(_compareByCreatedAtDesc);

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

    final merged = [...mockReviews, ...supabaseReviews]
      ..sort(_compareByCreatedAtDesc);

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
      final rows = await _supabase
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
      debugPrint(
        '[StoreReviewRepository] Mock mode store reviews fallback: $e',
      );
      return const [];
    }
  }

  Future<List<InternalReview>> _fetchSupabaseUserReviews({
    required String userId,
    required int limit,
  }) async {
    try {
      final rows = await _supabase
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
        .map(
          (row) => InternalReview.fromSupabase(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  int _compareByCreatedAtDesc(InternalReview a, InternalReview b) {
    final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
    final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  }
}
