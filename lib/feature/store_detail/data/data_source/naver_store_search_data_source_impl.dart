import 'dart:convert';

import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/data/model/naver_store_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NaverStoreSearchDataSourceImpl implements NaverStoreSearchDataSource {
  String _getEnv(String key) {
    final dotenvValue = dotenv.env[key]?.trim();
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }

    return String.fromEnvironment(
      key,
      defaultValue: 'NOT_FOUND',
    );
  }

  String get _clientId => _getEnv('NAVER_CLIENT_ID');

  String get _clientSecret => _getEnv('NAVER_CLIENT_SECRET');

  @override
  Future<NaverStoreInfo?> fetchExactStoreInfo({
    required String storeName,
    required String location,
  }) async {
    if (_clientId == 'NOT_FOUND' ||
        _clientId.isEmpty ||
        _clientSecret == 'NOT_FOUND' ||
        _clientSecret.isEmpty) {
      debugPrint(
        '[Naver API] Missing credentials. Check .env or --dart-define values.',
      );
      return null;
    }

    final query = _buildSearchQuery(storeName: storeName, location: location);
    final url = Uri.https('openapi.naver.com', '/v1/search/local.json', {
      'query': query,
      'display': '1',
    });

    try {
      final response = await http
          .get(
            url,
            headers: {
              'X-Naver-Client-Id': _clientId,
              'X-Naver-Client-Secret': _clientSecret,
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List?) ?? const [];
        if (items.isNotEmpty) {
          return _mapNaverStoreInfo(
            items.first as Map<String, dynamic>,
          );
        }
      } else {
        debugPrint(
          '[Naver API] Request failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[Naver API] Request exception: $e');
    }

    return null;
  }

  String _buildSearchQuery({
    required String storeName,
    required String location,
  }) {
    final cleanStoreName = storeName.trim();
    final locationHint = _buildLocationHint(location);

    if (cleanStoreName.isEmpty) {
      return locationHint;
    }

    if (locationHint.isEmpty) {
      return cleanStoreName;
    }

    return '$cleanStoreName $locationHint';
  }

  String _buildLocationHint(String location) {
    return location
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .take(2)
        .join(' ');
  }

  NaverStoreInfo _mapNaverStoreInfo(Map<String, dynamic> json) {
    final model = NaverStoreInfo.fromJson(json);
    return model.copyWith(
      title: model.title.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchStoresByKeyword({
    required String keyword,
    int display = 10,
  }) async {
    if (_clientId == 'NOT_FOUND' ||
        _clientId.isEmpty ||
        _clientSecret == 'NOT_FOUND' ||
        _clientSecret.isEmpty) {
      debugPrint(
        '[Naver API] Missing credentials. Check .env or --dart-define values.',
      );
      return const [];
    }

    final url = Uri.https('openapi.naver.com', '/v1/search/local.json', {
      'query': keyword,
      'display': display.toString(),
    });

    try {
      final response = await http
          .get(
            url,
            headers: {
              'X-Naver-Client-Id': _clientId,
              'X-Naver-Client-Secret': _clientSecret,
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List?) ?? const [];
        return items.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
          '[Naver API] Search request failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[Naver API] Search request exception: $e');
    }

    return const [];
  }

  @override
  Future<String?> fetchStoreImageUrl({
    required String storeName,
    required String address,
  }) async {
    final info = await fetchPlaceInfoFromMobileSearch(storeName: storeName);
    final placeId = info?['placeId'];
    if (placeId != null) {
      final summary = await fetchPlaceSummary(placeId: placeId);
      if (summary != null) {
        final imagesObj = summary['images'] as Map<String, dynamic>?;
        final imagesList = imagesObj?['images'] as List?;
        if (imagesList != null && imagesList.isNotEmpty) {
          final first = imagesList.first as Map<String, dynamic>?;
          return first?['origin'] as String? ?? first?['url'] as String?;
        }
      }
    }
    return null;
  }

  @override
  Future<Map<String, String?>?> fetchPlaceInfoFromMobileSearch({
    required String storeName,
  }) async {
    final encodedQuery = Uri.encodeComponent(storeName);
    final url = Uri.parse(
      'https://m.search.naver.com/search.naver?query=$encodedQuery',
    );
    debugPrint('[MobileSearch] 요청 URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        },
      ).timeout(const Duration(seconds: 8));

      debugPrint('[MobileSearch] HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final html = response.body;

        // place ID 추출 (8자리 이상)
        String? placeId;
        final idMatches = RegExp(r'id[=:](\d{8,})').allMatches(html);
        if (idMatches.isNotEmpty) {
          placeId = idMatches.first.group(1);
        }

        // 전화번호 추출 (href="tel:..." 패턴 우선, 그 다음 "phone":"..." 패턴)
        String? phone;
        final telHrefMatch = RegExp(r'href="tel:([^"]+)"').firstMatch(html);
        if (telHrefMatch != null) {
          phone = telHrefMatch.group(1);
        } else {
          final phoneJsonMatch =
              RegExp(r'"phone"\s*:\s*"([^"]+)"').firstMatch(html);
          if (phoneJsonMatch != null) {
            phone = phoneJsonMatch.group(1);
          }
        }

        debugPrint('[MobileSearch] 추출 결과 - placeId: $placeId, phone: $phone');

        if (placeId != null || phone != null) {
          return {'placeId': placeId, 'phone': phone};
        } else {
          debugPrint('[MobileSearch] placeId/phone 모두 찾을 수 없습니다.');
        }
      }
    } catch (e) {
      debugPrint('[MobileSearch] Exception: $e');
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchPlaceSummary({
    required String placeId,
  }) async {
    if (placeId.isEmpty) return null;

    final url = Uri.https('map.naver.com', '/p/api/place/summary/$placeId');
    debugPrint('[NaverSummary] 요청 URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Referer': 'https://map.naver.com/',
        },
      ).timeout(const Duration(seconds: 5));

      debugPrint('[NaverSummary] HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final placeDetail = decoded['data']?['placeDetail'] as Map<String, dynamic>?;
        if (placeDetail != null) {
          debugPrint('[NaverSummary] placeDetail 키: ${placeDetail.keys.toList()}');
          debugPrint('[NaverSummary] name=${placeDetail['name']}, phone=${placeDetail['phone']}');
          debugPrint('[NaverSummary] businessHours=${placeDetail['businessHours']}');
          debugPrint('[NaverSummary] images keys=${placeDetail['images']?.keys?.toList()}');
        } else {
          debugPrint('[NaverSummary] placeDetail이 null입니다. decoded keys: ${decoded.keys.toList()}');
        }
        return placeDetail;
      } else {
        debugPrint('[NaverSummary] 비정상 응답 body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
      }
    } catch (e) {
      debugPrint('[NaverSummary] Exception: $e');
    }
    return null;
  }
}
