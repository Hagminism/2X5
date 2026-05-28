import 'package:capstone_2026/core/domain/model/store/store_image.dart';

List<String> storeImageDisplayUrls(List<StoreImage> images) {
  return images
      .map((image) => image.imageUrl.trim())
      .where((url) => url.isNotEmpty)
      .toList();
}

String? storeCoverImageUrlFromJsonRows(dynamic raw) {
  if (raw is! List || raw.isEmpty) {
    return null;
  }

  final rows = raw
      .whereType<Map>()
      .map((row) => Map<String, dynamic>.from(row))
      .toList();
  if (rows.isEmpty) {
    return null;
  }

  rows.sort((a, b) {
    final aCover = (a['is_cover'] as bool?) ?? false;
    final bCover = (b['is_cover'] as bool?) ?? false;
    if (aCover != bCover) {
      return bCover ? 1 : -1;
    }
    final aOrder = (a['sort_order'] as num?)?.toInt() ?? 0;
    final bOrder = (b['sort_order'] as num?)?.toInt() ?? 0;
    return aOrder.compareTo(bOrder);
  });

  for (final row in rows) {
    final url = row['image_url']?.toString().trim() ?? '';
    if (url.isNotEmpty) {
      return url;
    }
  }
  return null;
}

String? storeHeaderImageUrl(List<StoreImage> images) {
  for (final image in images) {
    if (image.isCover) {
      final url = image.imageUrl.trim();
      if (url.isNotEmpty) {
        return url;
      }
    }
  }

  if (images.isEmpty) {
    return null;
  }

  final url = images.first.imageUrl.trim();
  return url.isEmpty ? null : url;
}

List<String?> storeSliderImages(List<String> imageUrls) {
  if (imageUrls.isEmpty) {
    return [null];
  }

  return imageUrls;
}
