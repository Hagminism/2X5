import 'package:capstone_2026/core/data/dto/studycafe/studycafe_detail_dto.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';

extension StudyCafeDetailDtoMapper on StudyCafeDetailDto {
  StudyCafeDetail toModel() {
    return StudyCafeDetail.fromJson({
      'id': id ?? '',
      'store_id': storeId ?? '',
      'layout_json': _normalizedLayoutJson(layoutJson),
      'usage_options': _normalizedUsageOptions(usageOptions),
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

  List<Map<String, Object?>> _normalizedUsageOptions(List<dynamic>? raw) {
    if (raw == null) {
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
