abstract interface class KakaoStoreSearchDataSource {
  Future<List<Map<String, dynamic>>> searchStoresByCoordinates({
    required String keyword,
    required double lat,
    required double lng,
    int radius = 1000,
  });
}
