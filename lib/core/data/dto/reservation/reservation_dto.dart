class ReservationDto {
  String? id;
  String? bookingDate;
  String? bookingTime;
  int? guestCount;
  String? createdAt;
  String? customerRequest;
  String? status;
  int? totalPrice;
  String? updatedAt;
  String? storeId;
  String? userId;

  ReservationDto({
    this.id,
    this.bookingDate,
    this.bookingTime,
    this.guestCount,
    this.createdAt,
    this.customerRequest,
    this.status,
    this.totalPrice,
    this.updatedAt,
    this.storeId,
    this.userId,
  });

  ReservationDto.fromJson(dynamic json) {
    id = json['id'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    guestCount = (json['guest_count'] as num?)?.toInt();
    createdAt = json['created_at'];
    customerRequest = json['customer_request'];
    status = json['status'];
    totalPrice = (json['total_price'] as num?)?.toInt();
    updatedAt = json['updated_at'];
    storeId = json['store_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['booking_date'] = bookingDate;
    map['booking_time'] = bookingTime;
    map['guest_count'] = guestCount;
    map['created_at'] = createdAt;
    map['customer_request'] = customerRequest;
    map['status'] = status;
    map['total_price'] = totalPrice;
    map['updated_at'] = updatedAt;
    map['store_id'] = storeId;
    map['user_id'] = userId;
    return map;
  }
}
