import 'package:url_launcher/url_launcher.dart';

class DeepLinkUtil {
  static const String _packageName = 'com.example.capstone_2026';

  /// 네이버 지도 앱으로 특정 장소의 리뷰 페이지를 엽니다.
  /// 앱이 설치되어 있지 않으면 외부 브라우저를 통해 웹 페이지를 엽니다.
  static Future<void> launchNaverMapReview(String placeId) async {
    final appUri = Uri.parse('nmap://place?id=$placeId&appname=$_packageName');
    final webUri = Uri.parse('https://m.place.naver.com/place/$placeId/review/visitor');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // 에러 발생 시 최후의 수단으로 웹 브라우저 실행 시도
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// 구글 지도 앱으로 특정 장소의 검색 결과(리뷰 포함)를 엽니다.
  static Future<void> launchGoogleMapSearch(String query) async {
    // Uri.https를 사용하여 쿼리 파라미터를 안전하게 인코딩합니다.
    final webUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw Exception('구글 지도를 실행할 수 없습니다: $e');
    }
  }
}
