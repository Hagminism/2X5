class BookmarkListItem {
  const BookmarkListItem({
    required this.bookmarkId,
    required this.storeId,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    this.reviewCount = 0,
    this.imageUrl,
    this.bookmarkedAt,
  });

  final String bookmarkId;
  final String storeId;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final DateTime? bookmarkedAt;
}
