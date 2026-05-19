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
}
