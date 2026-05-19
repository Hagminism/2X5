class PartnerStudyCafeLayoutSelectedLayoutItemDto {
  String? id;
  double? x;
  double? y;
  String? type;
  Map<String, dynamic>? seat;
  Map<String, dynamic>? element;

  PartnerStudyCafeLayoutSelectedLayoutItemDto({
    this.id,
    this.x,
    this.y,
    this.type,
    this.seat,
    this.element,
  });

  PartnerStudyCafeLayoutSelectedLayoutItemDto.fromJson(dynamic json) {
    if (json is! Map) {
      return;
    }
    id = json['id']?.toString();
    x = _doubleFromDynamic(json['x']);
    y = _doubleFromDynamic(json['y']);
    type = json['type']?.toString();
    seat = _mapFromDynamic(json['seat']);
    element = _mapFromDynamic(json['element']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'x': x,
      'y': y,
      'type': type,
      'seat': seat,
      'element': element,
    };
  }

  static double? _doubleFromDynamic(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  static Map<String, dynamic>? _mapFromDynamic(Object? value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(
      value.map(
        (dynamic key, dynamic v) => MapEntry(key.toString(), v),
      ),
    );
  }
}
