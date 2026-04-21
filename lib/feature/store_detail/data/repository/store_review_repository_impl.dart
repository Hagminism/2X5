import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_review_link_target.dart';
import 'package:capstone_2026/feature/store_detail/domain/repository/store_review_repository.dart';

class StoreReviewRepositoryImpl implements StoreReviewRepository {
  final NaverStoreSearchDataSource _naverStoreSearchDataSource;

  StoreReviewRepositoryImpl({
    required NaverStoreSearchDataSource naverStoreSearchDataSource,
  }) : _naverStoreSearchDataSource = naverStoreSearchDataSource;

  static const String _packageName = 'com.example.capstone_2026';

  @override
  Future<StoreReviewLinkTarget> getNaverReviewLinkTarget({
    required String storeName,
    required String location,
    String? placeId,
  }) async {
    if (placeId != null && placeId.isNotEmpty) {
      return StoreReviewLinkTarget(
        appUri: Uri.parse(
          'nmap://place?id=${Uri.encodeComponent(placeId)}'
          '&appname=${Uri.encodeComponent(_packageName)}',
        ),
        webUri: Uri.parse(
          'https://m.place.naver.com/place/$placeId/review/visitor',
        ),
      );
    }

    final info = await _naverStoreSearchDataSource.fetchExactStoreInfo(
      storeName: storeName,
      location: location,
    );
    final fallbackQuery = Uri.encodeComponent('$storeName $location');
    final fallbackWebUri = Uri.parse(
      'https://m.map.naver.com/search2/search.naver?query=$fallbackQuery',
    );

    if (info == null) {
      return StoreReviewLinkTarget(webUri: fallbackWebUri);
    }

    return StoreReviewLinkTarget(
      appUri: Uri.parse(
        'nmap://search?query=${Uri.encodeComponent(info.roadAddress)}'
        '&appname=${Uri.encodeComponent(_packageName)}',
      ),
      webUri: Uri.parse(
        info.link.isNotEmpty ? info.link : fallbackWebUri.toString(),
      ),
    );
  }

  @override
  Uri getGoogleMapSearchUri(String query) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }
}
