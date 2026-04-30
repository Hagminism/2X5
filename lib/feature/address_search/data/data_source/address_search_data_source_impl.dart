import 'dart:convert';

import 'package:capstone_2026/feature/address_search/data/data_source/address_search_data_source.dart';
import 'package:capstone_2026/feature/address_search/data/model/address_search_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddressSearchDataSourceImpl implements AddressSearchDataSource {
  String _getEnv(String key) {
    final dotenvValue = dotenv.env[key]?.trim();
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }
    return String.fromEnvironment(key, defaultValue: 'NOT_FOUND');
  }

  String get _clientId => _getEnv('NAVER_CLIENT_ID');

  String get _clientSecret => _getEnv('NAVER_CLIENT_SECRET');

  @override
  Future<List<AddressSearchItem>> searchAddresses(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const [];
    }
    if (_clientId == 'NOT_FOUND' ||
        _clientId.isEmpty ||
        _clientSecret == 'NOT_FOUND' ||
        _clientSecret.isEmpty) {
      throw StateError('주소 검색 API 키가 설정되지 않았습니다.');
    }

    final url = Uri.https('openapi.naver.com', '/v1/search/local.json', {
      'query': trimmedQuery,
      'display': '10',
      'sort': 'random',
    });

    final response = await http
        .get(
          url,
          headers: {
            'X-Naver-Client-Id': _clientId,
            'X-Naver-Client-Secret': _clientSecret,
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw StateError('주소 검색 요청에 실패했습니다. (${response.statusCode})');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? const [];
    return items
        .map((item) => _mapItem(item as Map<String, dynamic>))
        .whereType<AddressSearchItem>()
        .toList();
  }

  AddressSearchItem? _mapItem(Map<String, dynamic> json) {
    final rawAddress = (json['roadAddress'] as String?)?.trim();
    final fallbackAddress = (json['address'] as String?)?.trim();
    final address = (rawAddress?.isNotEmpty ?? false)
        ? rawAddress!
        : (fallbackAddress ?? '');
    if (address.isEmpty) {
      return null;
    }

    final mapx = double.tryParse('${json['mapx'] ?? ''}');
    final mapy = double.tryParse('${json['mapy'] ?? ''}');
    if (mapx == null || mapy == null) {
      return null;
    }

    final title = (json['title'] as String? ?? '')
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')
        .trim();

    return AddressSearchItem(
      title: title,
      address: address,
      latitude: mapy / 1e7,
      longitude: mapx / 1e7,
    );
  }
}
