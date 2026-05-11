class StudyCafeDetailDto {
  String? id;
  String? storeId;
  Map<String, dynamic>? layoutJson;
  List<dynamic>? usageOptions;
  String? createdAt;
  String? updatedAt;

  StudyCafeDetailDto({
    this.id,
    this.storeId,
    this.layoutJson,
    this.usageOptions,
    this.createdAt,
    this.updatedAt,
  });

  StudyCafeDetailDto.fromJson(dynamic json) {
    if (json is! Map) {
      return;
    }
    id = json['id']?.toString();
    storeId = json['store_id']?.toString();
    layoutJson = _mapFromDynamic(json['layout_json']);
    usageOptions = json['usage_options'] is List
        ? List<dynamic>.from(json['usage_options'] as List)
        : null;
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['store_id'] = storeId;
    map['layout_json'] = layoutJson;
    map['usage_options'] = usageOptions;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

  static Map<String, dynamic>? _mapFromDynamic(Object? value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(
      value.map(
        (Object? key, Object? v) => MapEntry(key.toString(), v),
      ),
    );
  }
}
