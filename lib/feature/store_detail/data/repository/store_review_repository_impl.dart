import 'package:capstone_2026/core/domain/model/review/review_reservation_ref.dart';
import 'package:capstone_2026/core/data/data_source/review/review_image_data_source.dart';
import 'package:capstone_2026/core/data/data_source/review/review_image_data_source_impl.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/google_places_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreReviewRepositoryImpl implements StoreReviewRepository {
  StoreReviewRepositoryImpl({
    required GooglePlacesDataSource googlePlacesDataSource,
    required NaverStoreSearchDataSource naverStoreSearchDataSource,
    required ReviewImageDataSource reviewImageDataSource,
    required SupabaseClient supabase,
  }) : _googlePlacesDataSource = googlePlacesDataSource,
       _naverStoreSearchDataSource = naverStoreSearchDataSource,
       _reviewImageDataSource = reviewImageDataSource,
       _supabase = supabase;

  final GooglePlacesDataSource _googlePlacesDataSource;
  final NaverStoreSearchDataSource _naverStoreSearchDataSource;
  final ReviewImageDataSource _reviewImageDataSource;
  final SupabaseClient _supabase;

  static const String _packageName = 'com.example.capstone_2026';
  static const String _reviewSelectColumns =
      'id, store_id, user_id, rating, content, image_urls, created_at, visit_purpose, users(name), stores(name)';

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
    final searchQuery = storeName.trim().isNotEmpty
        ? storeName.trim()
        : location;
    final fallbackQuery = Uri.encodeComponent(searchQuery);
    final fallbackWebUri = Uri.parse(
      'https://m.map.naver.com/search2/search.naver?query=$fallbackQuery',
    );

    if (info == null) {
      return StoreReviewLinkTarget(webUri: fallbackWebUri);
    }

    final appSearchQuery = info.roadAddress.trim().isNotEmpty
        ? info.roadAddress.trim()
        : searchQuery;

    return StoreReviewLinkTarget(
      appUri: Uri.parse(
        'nmap://search?query=${Uri.encodeComponent(appSearchQuery)}'
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
  Future<GooglePlaceReviewInfo?> fetchGooglePlaceReviewInfo({
    required String storeName,
    required String location,
  }) {
    return _googlePlacesDataSource.fetchReviewInfo(
      storeName: storeName,
      location: location,
    );
  }

  @override
  Future<List<InternalReview>> fetchStoreReviews({
    required String storeId,
    int limit = 20,
  }) async {
    return _fetchSupabaseStoreReviews(
      storeId: storeId,
      limit: limit,
    );
  }

  @override
  Future<List<InternalReview>> fetchUserReviews({
    required String userId,
    int limit = 20,
  }) async {
    return _fetchSupabaseUserReviews(
      userId: userId,
      limit: limit,
    );
  }

  @override
  Future<InternalReview> submitReview({
    required String storeId,
    required String storeName,
    required String userId,
    required String userName,
    required ReviewWriteResult review,
    ReviewReservationRef? reservationRef,
  }) async {
    _assertValidStoreId(storeId);

    final imageUrls = await _reviewImageDataSource.uploadReviewImages(
      userId: userId,
      filePaths: review.imagePaths,
    );

    final reservationPayload = await _buildReservationInsertPayload(
      reservationRef: reservationRef,
    );

    try {
      final rows = await _supabase
          .from('reviews')
          .insert({
            'store_id': storeId,
            'user_id': userId,
            'rating': review.rating,
            'content': review.content,
            'visit_purpose': review.visitTag,
            'image_urls': imageUrls,
            'is_visible': true,
            ...reservationPayload,
          })
          .select(_reviewSelectColumns)
          .limit(1);

      final reviews = _mapReviewRows(rows);
      if (reviews.isEmpty) {
        throw StateError('리뷰 저장 결과를 확인하지 못했습니다.');
      }

      final inserted = reviews.first;
      return InternalReview(
        id: inserted.id,
        storeId: inserted.storeId,
        userId: inserted.userId,
        userName: userName,
        storeName: storeName,
        rating: inserted.rating,
        content: inserted.content,
        imageUrls: inserted.imageUrls,
        createdAt: inserted.createdAt,
        visitPurpose: inserted.visitPurpose,
      );
    } on ReviewImageUploadException {
      rethrow;
    } catch (error) {
      debugPrint('[StoreReviewRepository] Supabase submit failed: $error');
      await _rollbackUploadedReviewImages(imageUrls: imageUrls);
      throw StateError('리뷰 등록에 실패했습니다. 잠시 후 다시 시도해 주세요.');
    }
  }

  @override
  Future<InternalReview> updateReview({
    required String reviewId,
    required ReviewWriteResult review,
  }) async {
    final rows = await _supabase
        .from('reviews')
        .update({
          'rating': review.rating,
          'content': review.content,
          'visit_purpose': review.visitTag,
        })
        .eq('id', reviewId)
        .select(_reviewSelectColumns)
        .limit(1);

    final reviews = _mapReviewRows(rows);
    if (reviews.isEmpty) {
      throw StateError('Review not found: $reviewId');
    }

    return reviews.first;
  }

  @override
  Future<void> deleteReview({
    required String reviewId,
  }) async {
    await _supabase.from('reviews').delete().eq('id', reviewId);
  }

  Future<void> _rollbackUploadedReviewImages({
    required List<String> imageUrls,
  }) async {
    if (imageUrls.isEmpty) {
      return;
    }

    await _reviewImageDataSource.deleteReviewImagesByPublicUrls(
      publicUrls: imageUrls,
    );
  }

  Future<List<InternalReview>> _fetchSupabaseStoreReviews({
    required String storeId,
    required int limit,
  }) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(_reviewSelectColumns)
          .eq('store_id', storeId)
          .eq('is_visible', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] fetch store reviews failed: $e');
      rethrow;
    }
  }

  Future<List<InternalReview>> _fetchSupabaseUserReviews({
    required String userId,
    required int limit,
  }) async {
    try {
      final rows = await _supabase
          .from('reviews')
          .select(_reviewSelectColumns)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return _mapReviewRows(rows);
    } catch (e) {
      debugPrint('[StoreReviewRepository] fetch user reviews failed: $e');
      rethrow;
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

  Future<Map<String, String>> _buildReservationInsertPayload({
    required ReviewReservationRef? reservationRef,
  }) async {
    if (reservationRef == null) {
      return const {};
    }

    final reservationId = reservationRef.reservationId.trim();
    if (reservationId.isEmpty) {
      throw StateError('유효하지 않은 예약 정보입니다.');
    }

    final row = await _supabase
        .from(reservationRef.source.reservationTable)
        .select('id')
        .eq('id', reservationId)
        .maybeSingle();

    if (row == null) {
      throw StateError('연결할 예약 정보를 찾을 수 없습니다.');
    }

    return {
      reservationRef.source.reservationColumn: reservationId,
    };
  }

  void _assertValidStoreId(String storeId) {
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    ).hasMatch(storeId);
    if (!isUuid) {
      throw StateError('유효하지 않은 업장 정보입니다.');
    }
  }
}
