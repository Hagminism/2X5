import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreReviewRepositoryImpl implements StoreReviewRepository {
  final NaverStoreSearchDataSource _naverStoreSearchDataSource;
  final Supabase _supabase;

  StoreReviewRepositoryImpl({
    required NaverStoreSearchDataSource naverStoreSearchDataSource,
    required Supabase supabase,
  }) : _naverStoreSearchDataSource = naverStoreSearchDataSource,
       _supabase = supabase;

  static const String _packageName = 'com.example.capstone_2026';

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
    try {
      final rows = await _supabase.client
          .from('reviews')
          .select(
            'id, store_id, user_id, user_name, store_name, rating, content, image_urls, created_at',
          )
          .eq('store_id', storeId)
          .eq('is_visible', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] Failed to fetch store reviews: $e');
      return const [];
    }
  }

  @override
  Future<List<InternalReview>> fetchUserReviews({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final rows = await _supabase.client
          .from('reviews')
          .select(
            'id, store_id, user_id, user_name, store_name, rating, content, image_urls, created_at',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] Failed to fetch user reviews: $e');
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
