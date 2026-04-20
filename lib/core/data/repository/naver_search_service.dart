import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NaverStoreInfo {
  final String title;
  final String link;
  final String roadAddress;

  NaverStoreInfo({
    required this.title,
    required this.link,
    required this.roadAddress,
  });

  factory NaverStoreInfo.fromJson(Map<String, dynamic> json) {
    return NaverStoreInfo(
      title: json['title']?.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '') ?? '',
      link: json['link'] ?? '',
      roadAddress: json['roadAddress'] ?? '',
    );
  }
}

class NaverSearchService {
  static String _getEnv(String key) {
    final dotenvValue = dotenv.env[key]?.trim();
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }

    return String.fromEnvironment(
      key,
      defaultValue: 'NOT_FOUND',
    );
  }

  static String get _clientId => _getEnv('NAVER_CLIENT_ID');

  static String get _clientSecret => _getEnv('NAVER_CLIENT_SECRET');

  static Future<NaverStoreInfo?> fetchExactStoreInfo(
    String storeName,
    String location,
  ) async {
    if (_clientId == 'NOT_FOUND' ||
        _clientId.isEmpty ||
        _clientSecret == 'NOT_FOUND' ||
        _clientSecret.isEmpty) {
      debugPrint(
        '[Naver API] Missing credentials. Check .env or --dart-define values.',
      );
      return null;
    }

    final cleanLocation = location.contains(' ')
        ? location.split(' ').first
        : location;
    final query = '$storeName $cleanLocation';
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
          return NaverStoreInfo.fromJson(
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
}
