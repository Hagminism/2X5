/// 지도 검색·조회에 사용하는 위경도 bbox(경계 상자) 유틸.
class MapAreaBounds {
  const MapAreaBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  static const double defaultLatOffset = 0.0135;
  static const double defaultLngOffset = 0.017;

  double get area {
    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;
    if (latSpan <= 0 || lngSpan <= 0) {
      return 0;
    }
    return latSpan * lngSpan;
  }
}

MapAreaBounds mapAreaBoundsFromCenter({
  required double lat,
  required double lng,
  double latOffset = MapAreaBounds.defaultLatOffset,
  double lngOffset = MapAreaBounds.defaultLngOffset,
}) {
  return MapAreaBounds(
    minLat: lat - latOffset,
    maxLat: lat + latOffset,
    minLng: lng - lngOffset,
    maxLng: lng + lngOffset,
  );
}

/// 두 bbox가 겹치는지 여부.
bool mapAreaBoundsOverlap(MapAreaBounds a, MapAreaBounds b) {
  return !(a.maxLat < b.minLat ||
      a.minLat > b.maxLat ||
      a.maxLng < b.minLng ||
      a.minLng > b.maxLng);
}

/// 교집합 bbox. 겹치지 않으면 null.
MapAreaBounds? mapAreaBoundsIntersection(MapAreaBounds a, MapAreaBounds b) {
  if (!mapAreaBoundsOverlap(a, b)) {
    return null;
  }
  return MapAreaBounds(
    minLat: a.minLat > b.minLat ? a.minLat : b.minLat,
    maxLat: a.maxLat < b.maxLat ? a.maxLat : b.maxLat,
    minLng: a.minLng > b.minLng ? a.minLng : b.minLng,
    maxLng: a.maxLng < b.maxLng ? a.maxLng : b.maxLng,
  );
}

/// [newBounds] 대비 [previousBounds]와 겹치는 비율 (0.0 ~ 1.0).
double mapAreaOverlapRatioAgainstNew({
  required MapAreaBounds newBounds,
  required MapAreaBounds previousBounds,
}) {
  final intersection = mapAreaBoundsIntersection(newBounds, previousBounds);
  if (intersection == null) {
    return 0;
  }
  final newArea = newBounds.area;
  if (newArea <= 0) {
    return 0;
  }
  return intersection.area / newArea;
}

/// API 검색을 건너뛰고 DB-only로 갈지 (겹침 비율 ≥ [threshold]).
bool shouldSkipExternalSearchForOverlap({
  required MapAreaBounds newBounds,
  MapAreaBounds? lastCrawledBounds,
  double threshold = 0.9,
}) {
  if (lastCrawledBounds == null) {
    return false;
  }
  final ratio = mapAreaOverlapRatioAgainstNew(
    newBounds: newBounds,
    previousBounds: lastCrawledBounds,
  );
  return ratio >= threshold;
}

/// 마지막 크롤 영역에 이번 검색 영역을 합친 bbox.
MapAreaBounds mapAreaBoundsUnion(MapAreaBounds a, MapAreaBounds b) {
  return MapAreaBounds(
    minLat: a.minLat < b.minLat ? a.minLat : b.minLat,
    maxLat: a.maxLat > b.maxLat ? a.maxLat : b.maxLat,
    minLng: a.minLng < b.minLng ? a.minLng : b.minLng,
    maxLng: a.maxLng > b.maxLng ? a.maxLng : b.maxLng,
  );
}
