class StoreLayoutDetailDto {
  String? id;
  String? storeId;
  Map<String, dynamic>? layoutJson;
  String? createdAt;
  String? updatedAt;

  StoreLayoutDetailDto({
    this.id,
    this.storeId,
    this.layoutJson,
    this.createdAt,
    this.updatedAt,
  });

  StoreLayoutDetailDto.fromJson(dynamic json) {
    if (json is! Map) {
      return;
    }
    id = json['id']?.toString();
    storeId = json['store_id']?.toString();
    layoutJson = _mapFromDynamic(json['layout_json']);
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['store_id'] = storeId;
    map['layout_json'] = layoutJson;
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
