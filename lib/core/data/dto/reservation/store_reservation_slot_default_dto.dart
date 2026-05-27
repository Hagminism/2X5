class StoreReservationSlotDefaultDto {
  String? storeId;
  String? slotTime;
  int? maxGuestCount;
  String? updatedAt;
  bool? isOpen;

  StoreReservationSlotDefaultDto({
    this.storeId,
    this.slotTime,
    this.maxGuestCount,
    this.updatedAt,
    this.isOpen,
  });

  StoreReservationSlotDefaultDto.fromJson(dynamic json) {
    storeId = json['store_id']?.toString();
    slotTime = json['slot_time']?.toString();
    maxGuestCount = (json['max_guest_count'] as num?)?.toInt();
    updatedAt = json['updated_at']?.toString();
    isOpen = json['is_open'] as bool? ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'slot_time': slotTime,
      'max_guest_count': maxGuestCount,
      'is_open': isOpen,
      'updated_at': updatedAt,
    };
  }
}
