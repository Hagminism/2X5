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
    this.visitPurpose,
  });

  final String id;
  final String storeId;
  final String userId;
  final String userName;
  final String storeName;
  final double rating;
  final String content;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final String? visitPurpose;

  factory InternalReview.fromSupabase(Map<String, dynamic> json) {
    return InternalReview(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: _parseRelatedName(json['user_name'], json['users']) ?? '익명 사용자',
      storeName: _parseRelatedName(json['store_name'], json['stores']) ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      content: json['content']?.toString() ?? '',
      imageUrls: List<String>.from(json['image_urls'] as List? ?? const []),
      createdAt: _parseDateTime(json['created_at']),
      visitPurpose: _parseVisitPurpose(json['visit_purpose']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static String? _parseVisitPurpose(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static String? _parseRelatedName(dynamic flatValue, dynamic relatedValue) {
    final flatText = flatValue?.toString().trim();
    if (flatText != null && flatText.isNotEmpty) {
      return flatText;
    }

    if (relatedValue is Map) {
      final relatedText = relatedValue['name']?.toString().trim();
      if (relatedText != null && relatedText.isNotEmpty) {
        return relatedText;
      }
    }

    return null;
  }
}
