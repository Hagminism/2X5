import 'dart:convert';
import 'package:capstone_2026/feature/store_detail/data/data_source/kakao_store_search_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class KakaoStoreSearchDataSourceImpl implements KakaoStoreSearchDataSource {
  String _getEnv(String key) {
    final dotenvValue = dotenv.env[key]?.trim();
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }
    return String.fromEnvironment(key, defaultValue: 'NOT_FOUND');
  }

  String get _restApiKey => _getEnv('KAKAO_REST_API_KEY');

  @override
  Future<List<Map<String, dynamic>>> searchStoresByCoordinates({
    required String keyword,
    required double lat,
    required double lng,
    int radius = 1000,
  }) async {
    if (_restApiKey == 'NOT_FOUND' || _restApiKey.isEmpty) {
      debugPrint(
        '[Kakao API] Missing KAKAO_REST_API_KEY in .env or --dart-define',
      );
      return const [];
    }

    final url = Uri.https('dapi.kakao.com', '/v2/local/search/keyword.json', {
      'query': keyword,
      'x': lng.toString(),
      'y': lat.toString(),
      'radius': radius.toString(),
      'size': '15',
    });

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'KakaoAK $_restApiKey',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final docs = (data['documents'] as List?) ?? const [];
        return docs.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
          '[Kakao API] Request failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[Kakao API] Exception: $e');
    }
    return const [];
  }
}
