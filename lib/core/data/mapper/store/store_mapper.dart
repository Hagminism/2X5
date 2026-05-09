import 'package:capstone_2026/core/data/dto/store/store_dto.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';

extension StoreDtoMapper on StoreDto {
  Store toModel() {
    return Store(
      id: id ?? '',
      ownerId: ownerId ?? '',
      name: name ?? '',
      category: category ?? '',
      businessNumber: businessNumber ?? '',
      address: address ?? '',
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      naverPlaceId: naverPlaceId,
      contact: contact ?? '',
      operatingHours: operatingHours ?? const {},
      rating: rating ?? 0,
      depositEnabled: depositEnabled ?? false,
      depositAmount: depositAmount ?? 0,
      createdAt: _parseDateTime(createdAt),
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

extension StoreToDtoMapper on Store {
  StoreDto toDto() {
    return StoreDto(
      id: id,
      ownerId: ownerId,
      name: name,
      category: category,
      businessNumber: businessNumber,
      address: address,
      latitude: latitude,
      longitude: longitude,
      naverPlaceId: naverPlaceId,
      contact: contact,
      operatingHours: operatingHours,
      rating: rating,
      depositEnabled: depositEnabled,
      depositAmount: depositAmount,
      createdAt: createdAt?.toIso8601String(),
    );
  }
}
