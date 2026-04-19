import 'package:url_launcher/url_launcher.dart';

class DeepLinkUtil {
  static const String _packageName = 'com.example.capstone_2026';

  /// 네이버 지도 앱으로 특정 장소의 리뷰 페이지를 엽니다.
  static Future<bool> launchNaverMapReview(String placeId) async {
    final appUri = Uri.parse('nmap://place?id=$placeId&appname=$_packageName');
    final webUri = Uri.parse('https://m.place.naver.com/place/$placeId/review/visitor');

    try {
      if (await canLaunchUrl(appUri)) {
        return await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ [DeepLink Error] 네이버 지도 실행 실패: $e');
      return false;
    }
  }

  /// 구글 지도 앱으로 특정 장소의 검색 결과(리뷰 포함)를 엽니다.
  static Future<bool> launchGoogleMapSearch(String query) async {
    final webUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('❌ [DeepLink Error] 구글 지도 실행 실패: $e');
      return false;
    }
  }
}
