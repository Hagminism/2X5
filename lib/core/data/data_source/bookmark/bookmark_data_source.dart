abstract interface class BookmarkDataSource {
  /// 이 가게를 찜했는지
  Future<bool> exists({
    required String userId,
    required String storeId,
  });

  /// 찜 추가
  Future<void> add({
    required String userId,
    required String storeId,
  });

  /// 찜 해제
  Future<void> remove({
    required String userId,
    required String storeId,
  });

  /// 내 찜 목록 (store_id 목록 + stores 정보는 impl에서 join)
  Future<List<Map<String, dynamic>>> findByUserId(String userId);
}
