import 'package:capstone_2026/core/data/dto/store/store_layout_detail_dto.dart';
import 'package:capstone_2026/core/domain/model/store/store_layout_detail.dart';

extension StoreLayoutDetailDtoMapper on StoreLayoutDetailDto {
  StoreLayoutDetail toModel() {
    final normalized = _normalizedLayoutJson(layoutJson);
    return StoreLayoutDetail.fromJson({
      'id': id ?? '',
      'store_id': storeId ?? '',
      'seats': normalized['seats'],
      'elements': normalized['elements'],
      'created_at': createdAt,
      'updated_at': updatedAt,
    });
  }

  Map<String, Object?> _normalizedLayoutJson(Map<String, dynamic>? raw) {
    if (raw == null) {
      return {
        'seats': <Map<String, Object?>>[],
        'elements': <Map<String, Object?>>[],
      };
    }
    return {
      'seats': _normalizedSeatMaps(raw['seats']),
      'elements': _normalizedElementMaps(raw['elements']),
    };
  }

  List<Map<String, Object?>> _normalizedSeatMaps(Object? raw) {
    if (raw is! List) {
      return [];
    }
    return raw
        .map((Object? item) {
          if (item is! Map) {
            return null;
          }
          return Map<String, Object?>.from(
            item.map(
              (Object? key, Object? value) => MapEntry(key.toString(), value),
            ),
          );
        })
        .whereType<Map<String, Object?>>()
        .toList();
  }

  List<Map<String, Object?>> _normalizedElementMaps(Object? raw) {
    if (raw is! List) {
      return [];
    }
    return raw
        .map((Object? item) {
          if (item is! Map) {
            return null;
          }
          return Map<String, Object?>.from(
            item.map(
              (Object? key, Object? value) => MapEntry(key.toString(), value),
            ),
          );
        })
        .whereType<Map<String, Object?>>()
        .toList();
  }
}
