import 'package:capstone_2026/core/domain/model/store/store_image.dart';

List<String> storeImageDisplayUrls(List<StoreImage> images) {
  return images
      .map((image) => image.imageUrl.trim())
      .where((url) => url.isNotEmpty)
      .toList();
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
