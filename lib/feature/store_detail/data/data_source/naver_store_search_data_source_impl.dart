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
    if (kIsWeb) {
      return _fetchPlaceInfoFromMobileSearchViaProxy(storeName: storeName);
    }

    final encodedQuery = Uri.encodeComponent(storeName);
    final url = Uri.parse(
      'https://m.search.naver.com/search.naver?query=$encodedQuery',
    );
    debugPrint('[MobileSearch] 요청 URL: $url');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
            },
          )
          .timeout(const Duration(seconds: 8));

      debugPrint('[MobileSearch] HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseMobileSearchHtml(response.body);
      }
    } catch (e) {
      debugPrint('[MobileSearch] Exception: $e');
    }
    return null;
  }

  Future<Map<String, String?>?> _fetchPlaceInfoFromMobileSearchViaProxy({
    required String storeName,
  }) async {
    final url = Uri.parse('$_proxyUrl/api/mobile-search').replace(
      queryParameters: {'query': storeName},
    );
    debugPrint('[MobileSearch] Proxy 요청 URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      debugPrint('[MobileSearch] Proxy HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          final placeId = decoded['placeId']?.toString();
          final phone = decoded['phone']?.toString();
          debugPrint(
            '[MobileSearch] Proxy 추출 결과 - placeId: $placeId, phone: $phone',
          );
          if ((placeId != null && placeId.isNotEmpty) ||
              (phone != null && phone.isNotEmpty)) {
            return {'placeId': placeId, 'phone': phone};
          }
          debugPrint('[MobileSearch] placeId/phone 모두 찾을 수 없습니다.');
        }
      } else {
        debugPrint('[MobileSearch] Proxy 비정상 응답: ${response.body}');
      }
    } catch (e) {
      debugPrint('[MobileSearch] Proxy Exception: $e');
    }
    return null;
  }

  Map<String, String?>? _parseMobileSearchHtml(String html) {
    String? placeId;
    final idMatches = RegExp(r'id[=:](\d{8,})').allMatches(html);
    if (idMatches.isNotEmpty) {
      placeId = idMatches.first.group(1);
    }

    String? phone;
    final telHrefMatch = RegExp(r'href="tel:([^"]+)"').firstMatch(html);
    if (telHrefMatch != null) {
      phone = telHrefMatch.group(1);
    } else {
      final phoneJsonMatch = RegExp(
        r'"phone"\s*:\s*"([^"]+)"',
      ).firstMatch(html);
      if (phoneJsonMatch != null) {
        phone = phoneJsonMatch.group(1);
      }
    }

    debugPrint('[MobileSearch] 추출 결과 - placeId: $placeId, phone: $phone');

    if (placeId != null || phone != null) {
      return {'placeId': placeId, 'phone': phone};
    }
    debugPrint('[MobileSearch] placeId/phone 모두 찾을 수 없습니다.');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchPlaceSummary({
    required String placeId,
  }) async {
    if (placeId.isEmpty) return null;

    if (kIsWeb) {
      return _fetchPlaceSummaryViaProxy(placeId: placeId);
    }

    final url = Uri.https('map.naver.com', '/p/api/place/summary/$placeId');
    debugPrint('[NaverSummary] 요청 URL: $url');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Referer': 'https://map.naver.com/',
            },
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('[NaverSummary] HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        return _extractPlaceDetailFromSummaryResponse(decoded);
      } else {
        debugPrint(
          '[NaverSummary] 비정상 응답 body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}',
        );
      }
    } catch (e) {
      debugPrint('[NaverSummary] Exception: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchPlaceSummaryViaProxy({
    required String placeId,
  }) async {
    final url = Uri.parse('$_proxyUrl/api/place/$placeId/summary');
    debugPrint('[NaverSummary] Proxy 요청 URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      debugPrint('[NaverSummary] Proxy HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded == null) {
          debugPrint('[NaverSummary] Proxy placeDetail이 null입니다.');
          return null;
        }
        if (decoded is Map<String, dynamic>) {
          return _logPlaceDetail(decoded);
        }
        if (decoded is Map) {
          return _logPlaceDetail(Map<String, dynamic>.from(decoded));
        }
      } else {
        debugPrint(
          '[NaverSummary] Proxy 비정상 응답 body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}',
        );
      }
    } catch (e) {
      debugPrint('[NaverSummary] Proxy Exception: $e');
    }
    return null;
  }

  Map<String, dynamic>? _extractPlaceDetailFromSummaryResponse(
    Map<String, dynamic> decoded,
  ) {
    final placeDetail = decoded['data']?['placeDetail'] as Map<String, dynamic>?;
    if (placeDetail != null) {
      return _logPlaceDetail(placeDetail);
    }
    debugPrint(
      '[NaverSummary] placeDetail이 null입니다. decoded keys: ${decoded.keys.toList()}',
    );
    return null;
  }

  Map<String, dynamic> _logPlaceDetail(Map<String, dynamic> placeDetail) {
    debugPrint('[NaverSummary] placeDetail 키: ${placeDetail.keys.toList()}');
    debugPrint(
      '[NaverSummary] name=${placeDetail['name']}, phone=${placeDetail['phone']}',
    );
    debugPrint(
      '[NaverSummary] businessHours=${placeDetail['businessHours']}',
    );
    debugPrint(
      '[NaverSummary] images keys=${placeDetail['images']?.keys?.toList()}',
    );
    return placeDetail;
  }

  @override
  Future<Map<String, dynamic>?> fetchPlaceOperatingHours({
    required String placeId,
    String businessType = 'restaurant',
  }) async {
    if (placeId.isEmpty) return null;

    final normalizedType = businessType.trim().isEmpty
        ? 'restaurant'
        : businessType.trim();
    final url = Uri.parse('$_proxyUrl/api/place/$placeId/hours').replace(
      queryParameters: {'business_type': normalizedType},
    );
    debugPrint('[NaverHours] Requesting URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        debugPrint(
          '[NaverHours] Unexpected response body format: ${response.body}',
        );
      } else {
        debugPrint(
          '[NaverHours] Fail status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e, stack) {
      debugPrint('[NaverHours] Exception occurred: $e');
      debugPrint('[NaverHours] Stacktrace: $stack');
    }

    return null;
  }

  String get _proxyUrl {
    final url = _getEnv('NAVER_PROXY_URL');
    return url == 'NOT_FOUND' || url.isEmpty ? 'http://localhost:8000' : url;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStoreMenus({
    required String placeId,
  }) async {
    if (placeId.isEmpty) return const [];

    final url = Uri.parse('$_proxyUrl/api/place/$placeId/menu');
    debugPrint('[NaverMenus] Requesting URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded.containsKey('menus')) {
          final menusList = decoded['menus'] as List?;
          if (menusList != null) {
            return menusList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          }
        }
        debugPrint(
          '[NaverMenus] Unexpected response body format: ${response.body}',
        );
      } else {
        debugPrint(
          '[NaverMenus] Fail status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e, stack) {
      debugPrint('[NaverMenus] Exception occurred: $e');
      debugPrint('[NaverMenus] Stacktrace: $stack');
    }

    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchStoreReviews({
    required String placeId,
    int page = 1,
    int size = 15,
    String? after,
  }) async {
    if (placeId.isEmpty) return const [];

    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (after != null) {
      queryParams['after'] = after;
    }
    final url = Uri.parse(
      '$_proxyUrl/api/place/$placeId/review',
    ).replace(queryParameters: queryParams);
    debugPrint('[NaverReviews] Requesting URL: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded.containsKey('reviews')) {
          final reviewsList = decoded['reviews'] as List?;
          if (reviewsList != null) {
            return reviewsList
                .map((e) => Map<String, dynamic>.from(e as Map))
                .where(
                  (review) =>
                      (review['body'] as String? ?? '').trim().isNotEmpty,
                )
                .toList();
          }
        }
        debugPrint(
          '[NaverReviews] Unexpected response body format: ${response.body}',
        );
      } else {
        debugPrint(
          '[NaverReviews] Fail status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e, stack) {
      debugPrint('[NaverReviews] Exception occurred: $e');
      debugPrint('[NaverReviews] Stacktrace: $stack');
    }

    return const [];
  }
}
