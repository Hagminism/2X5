class StoreDto {
  String? id;
  String? ownerId;
  String? name;
  String? category;
  String? businessNumber;
  String? address;
  double? latitude;
  double? longitude;
  String? naverPlaceId;
  String? contact;
  String? phone;
  Map<String, dynamic>? operatingHours;
  double? rating;
  bool? depositEnabled;
  int? depositAmount;
  int? reservationSlotMinutes;
  String? createdAt;

  StoreDto({
    this.id,
    this.ownerId,
    this.name,
    this.category,
    this.businessNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.naverPlaceId,
    this.contact,
    this.phone,
    this.operatingHours,
    this.rating,
    this.depositEnabled,
    this.depositAmount,
    this.reservationSlotMinutes,
    this.createdAt,
  });

  StoreDto.fromJson(dynamic json) {
    id = json['id'];
    ownerId = json['owner_id'];
    name = json['name'];
    category = json['category'];
    businessNumber = json['business_number'];
    address = json['address'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    naverPlaceId = json['naver_place_id'];
    contact = json['contact'];
    final phoneRaw = json['phone']?.toString().trim();
    phone = (phoneRaw == null || phoneRaw.isEmpty) ? null : phoneRaw;
    operatingHours = (json['operating_hours'] as Map?)?.cast<String, dynamic>();
    rating = (json['rating'] as num?)?.toDouble();
    depositEnabled = json['deposit_enabled'];
    depositAmount = (json['deposit_amount'] as num?)?.toInt();
    reservationSlotMinutes = (json['reservation_slot_minutes'] as num?)
        ?.toInt();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['owner_id'] = ownerId;
    map['name'] = name;
    map['category'] = category;
    map['business_number'] = businessNumber;
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['naver_place_id'] = naverPlaceId;
    map['contact'] = contact;
    map['phone'] = phone;
    map['operating_hours'] = operatingHours;
    map['rating'] = rating;
    map['deposit_enabled'] = depositEnabled;
    map['deposit_amount'] = depositAmount;
    map['reservation_slot_minutes'] = reservationSlotMinutes;
    map['created_at'] = createdAt;
    return map;
  }
}