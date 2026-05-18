import 'dart:convert';

import 'package:capstone_2026/feature/store_detail/data/data_source/google_places_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GooglePlacesDataSourceImpl implements GooglePlacesDataSource {
  static const String _apiHost = 'places.googleapis.com';
  static const String _apiKeyName = 'GOOGLE_PLACES_API_KEY';

  String get _apiKey {
    final dotenvValue = dotenv.env[_apiKeyName]?.trim();
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }

    return const String.fromEnvironment(_apiKeyName);
  }

  @override
  Future<GooglePlaceReviewInfo?> fetchReviewInfo({
    required String storeName,
    required String location,
  }) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      debugPrint('[Google Places] Missing $_apiKeyName.');
      return null;
    }

    final query = [
      storeName.trim(),
      location.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
    if (query.isEmpty) {
      return null;
    }

    try {
      debugPrint('[Google Places] Search query: $query');
      final placeId = await _fetchPlaceId(apiKey: apiKey, query: query);
      if (placeId == null || placeId.isEmpty) {
        debugPrint('[Google Places] No place found.');
        return null;
      }

      debugPrint('[Google Places] Found placeId: $placeId');
      return _fetchPlaceDetails(apiKey: apiKey, placeId: placeId);
    } catch (e) {
      debugPrint('[Google Places] Request exception: $e');
      return null;
    }
  }

  Future<String?> _fetchPlaceId({
    required String apiKey,
    required String query,
  }) async {
    final response = await http
        .post(
          Uri.https(_apiHost, '/v1/places:searchText'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': 'places.id',
          },
          body: jsonEncode({
            'textQuery': query,
            'languageCode': 'ko',
            'regionCode': 'KR',
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      debugPrint(
        '[Google Places] Text search failed: '
        '${response.statusCode} ${response.body}',
      );
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final places = data['places'];
    if (places is! List || places.isEmpty) {
      debugPrint('[Google Places] Text search returned empty places.');
      return null;
    }

    final firstPlace = places.first;
    if (firstPlace is! Map<String, dynamic>) {
      return null;
    }

    return firstPlace['id']?.toString();
  }

  Future<GooglePlaceReviewInfo?> _fetchPlaceDetails({
    required String apiKey,
    required String placeId,
  }) async {
    final response = await http
        .get(
          Uri.https(_apiHost, '/v1/places/$placeId', {
            'languageCode': 'ko',
          }),
          headers: {
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask':
                'id,googleMapsUri,rating,userRatingCount,reviewSummary',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      debugPrint(
        '[Google Places] Details failed: '
        '${response.statusCode} ${response.body}',
      );
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final info = GooglePlaceReviewInfo(
      placeId: data['id']?.toString() ?? placeId,
      googleMapsUri: _parseUri(data['googleMapsUri']),
      rating: (data['rating'] as num?)?.toDouble(),
      userRatingCount: (data['userRatingCount'] as num?)?.toInt(),
      reviewSummary: _parseReviewSummary(data['reviewSummary']),
    );
    debugPrint(
      '[Google Places] Details loaded: '
      'rating=${info.rating}, reviews=${info.userRatingCount}, '
      'hasSummary=${info.hasSummary}, mapsUri=${info.googleMapsUri != null}',
    );
    return info;
  }

  Uri? _parseUri(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Uri.tryParse(raw);
  }

  String? _parseReviewSummary(dynamic value) {
    if (value is String) {
      return value.trim().isEmpty ? null : value.trim();
    }

    if (value is Map) {
      final text = value['text'];
      if (text is String) {
        return text.trim().isEmpty ? null : text.trim();
      }

      if (text is Map) {
        final localizedText = text['text']?.toString().trim();
        if (localizedText != null && localizedText.isNotEmpty) {
          return localizedText;
        }
      }
    }

    return null;
  }
}
