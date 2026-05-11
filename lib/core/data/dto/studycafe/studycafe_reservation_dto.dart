class StudyCafeReservationDto {
  String? id;
  String? storeId;
  String? userId;
  String? seatId;
  int? durationMinutes;
  String? startAt;
  String? endAt;
  String? status;
  String? createdAt;
  String? updatedAt;

  StudyCafeReservationDto({
    this.id,
    this.storeId,
    this.userId,
    this.seatId,
    this.durationMinutes,
    this.startAt,
    this.endAt,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  StudyCafeReservationDto.fromJson(dynamic json) {
    if (json is! Map) {
      return;
    }
    id = json['id']?.toString();
    storeId = json['store_id']?.toString();
    userId = json['user_id']?.toString();
    seatId = json['seat_id']?.toString();
    durationMinutes = _intFromDynamic(json['duration_minutes']);
    startAt = json['start_at']?.toString();
    endAt = json['end_at']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['store_id'] = storeId;
    map['user_id'] = userId;
    map['seat_id'] = seatId;
    map['duration_minutes'] = durationMinutes;
    map['start_at'] = startAt;
    map['end_at'] = endAt;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

  static int? _intFromDynamic(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
