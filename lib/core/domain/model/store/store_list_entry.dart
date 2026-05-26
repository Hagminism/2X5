import 'package:capstone_2026/core/domain/model/store/store.dart';

/// 목록 API 한 번에 매장 + 대표 이미지 URL.
class StoreListEntry {
  const StoreListEntry({
    required this.store,
    this.coverImageUrl,
  });

  final Store store;
  final String? coverImageUrl;
}
