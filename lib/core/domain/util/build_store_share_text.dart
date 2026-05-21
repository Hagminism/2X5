/// 상세 화면 진입 경로별 공유 딥링크·문구 생성.
enum StoreShareRoute {
  home,
  map,
  search,
}

String buildStoreShareText({
  required StoreShareRoute route,
  required String storeId,
  required String name,
  required String address,
  String? naverPlaceId,
}) {
  final trimmedName = name.trim();
  final trimmedAddress = address.trim();
  final trimmedStoreId = storeId.trim();

  final buffer = StringBuffer();
  if (trimmedName.isNotEmpty) {
    buffer.writeln(trimmedName);
  }
  if (trimmedAddress.isNotEmpty) {
    buffer.writeln(trimmedAddress);
  }

  if (trimmedStoreId.isNotEmpty) {
    final deepLink = switch (route) {
      StoreShareRoute.home => 'team2x5://home/information/$trimmedStoreId',
      StoreShareRoute.map =>
        'team2x5://map/map-store-information/$trimmedStoreId',
      StoreShareRoute.search =>
        'team2x5://map/search/search-store-information/$trimmedStoreId',
    };
    buffer.writeln(deepLink);
  }

  final trimmedPlaceId = naverPlaceId?.trim() ?? '';
  if (trimmedPlaceId.isNotEmpty) {
    buffer.writeln(
      'https://m.place.naver.com/place/$trimmedPlaceId/home',
    );
  }

  return buffer.toString().trim();
}
