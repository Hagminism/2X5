class StoreScheduleExceptionDto {
  String? storeId;
  String? exceptionDate;
  bool? isClosed;
  String? openTime;
  String? closeTime;
  List<Map<String, dynamic>>? slotOverrides;
  String? updatedAt;

  StoreScheduleExceptionDto({
    this.storeId,
    this.exceptionDate,
    this.isClosed,
    this.openTime,
    this.closeTime,
    this.slotOverrides,
    this.updatedAt,
  });

  StoreScheduleExceptionDto.fromJson(dynamic json) {
    storeId = json['store_id']?.toString();
    exceptionDate = json['exception_date']?.toString();
    isClosed = json['is_closed'] as bool? ?? false;
    openTime = json['open_time']?.toString();
    closeTime = json['close_time']?.toString();
    final rawOverrides = json['slot_overrides'];
    if (rawOverrides is List) {
      slotOverrides = rawOverrides
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } else {
      slotOverrides = const [];
    }
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'exception_date': exceptionDate,
      'is_closed': isClosed,
      'open_time': openTime,
      'close_time': closeTime,
      'slot_overrides': slotOverrides ?? [],
      'updated_at': updatedAt,
    };
  }
}
