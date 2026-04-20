import 'package:capstone_2026/core/data/repository/naver_search_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkUtil {
  static const String _packageName = 'com.example.capstone_2026';

  static Future<bool> launchNaverMapReview({
    required String storeName,
    required String location,
    String? placeId,
  }) async {
    if (placeId != null && placeId.isNotEmpty) {
      final appUri = Uri.parse('nmap://place?id=$placeId&appname=$_packageName');
      final webUri = Uri.parse(
        'https://m.place.naver.com/place/$placeId/review/visitor',
      );

      try {
        if (await canLaunchUrl(Uri.parse('nmap://'))) {
          return await launchUrl(appUri, mode: LaunchMode.externalApplication);
        }

        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[DeepLink] Failed to open Naver place review by id: $e');
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    }

    final info = await NaverSearchService.fetchExactStoreInfo(storeName, location);

    if (info == null) {
      debugPrint('[DeepLink] Naver API returned no store info. Falling back to search.');
      return _launchNaverSearchFallback(storeName, location);
    }

    final appUri = Uri.parse(
      'nmap://search?query=${Uri.encodeComponent(info.roadAddress)}&appname=$_packageName',
    );
    final fallbackQuery = Uri.encodeComponent('$storeName $location');
    final webUri = Uri.parse(
      info.link.isNotEmpty
          ? info.link
          : 'https://m.map.naver.com/search2/search.naver?query=$fallbackQuery',
    );

    try {
      if (await canLaunchUrl(Uri.parse('nmap://'))) {
        return await launchUrl(appUri, mode: LaunchMode.externalApplication);
      }

      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[DeepLink] Failed to open Naver review from API result: $e');
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> _launchNaverSearchFallback(String name, String loc) async {
    final query = '$name $loc';
    final webUri = Uri.parse(
      'https://m.map.naver.com/search2/search.naver?query=${Uri.encodeComponent(query)}',
    );
    return await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> launchGoogleMapSearch(String query) async {
    final webUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[DeepLink Error] Failed to open Google Maps: $e');
      return false;
    }
  }
}
