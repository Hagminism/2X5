class StudyCafeSeatHoldDto {
  String? id;
  String? storeId;
  String? userId;
  String? seatId;
  String? expiresAt;
  String? status;
  String? createdAt;
  String? updatedAt;

  StudyCafeSeatHoldDto({
    this.id,
    this.storeId,
    this.userId,
    this.seatId,
    this.expiresAt,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  StudyCafeSeatHoldDto.fromJson(dynamic json) {
    if (json is! Map) {
      return;
    }
    id = json['id']?.toString();
    storeId = json['store_id']?.toString();
    userId = json['user_id']?.toString();
    seatId = json['seat_id']?.toString();
    expiresAt = json['expires_at']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }
}
