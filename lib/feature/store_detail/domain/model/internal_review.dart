class InternalReview {
  const InternalReview({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.storeName,
    required this.rating,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String userId;
  final String userName;
  final String storeName;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;

  factory InternalReview.fromSupabase(Map<String, dynamic> json) {
    return InternalReview(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '익명 사용자',
      storeName: json['store_name']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      content: json['content']?.toString() ?? '',
      imageUrls: List<String>.from(json['image_urls'] as List? ?? const []),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
