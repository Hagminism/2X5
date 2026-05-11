import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_detail.freezed.dart';
part 'studycafe_detail.g.dart';

@freezed
abstract class StudyCafeDetail with _$StudyCafeDetail {
  const factory StudyCafeDetail({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(
      name: 'layout_json',
      fromJson: _seatsFromLayoutJson,
      toJson: _seatsToLayoutJson,
    )
    @Default([])
    List<StudyCafeSeat> seats,
    @JsonKey(
      name: 'layout_json',
      fromJson: _elementsFromLayoutJson,
      includeToJson: false,
    )
    @Default([])
    List<StudyCafeLayoutElement> elements,
    @JsonKey(name: 'usage_options', fromJson: _usageOptionsFromJson)
    @Default([])
    List<StudyCafeUsageOption> usageOptions,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StudyCafeDetail;

  factory StudyCafeDetail.empty(String storeId) {
    return StudyCafeDetail(
      id: '',
      storeId: storeId,
      seats: const [],
      elements: const [],
      usageOptions: const [
        StudyCafeUsageOption(
          durationMinutes: 120,
          price: 0,
          isEnabled: true,
        ),
      ],
    );
  }

  factory StudyCafeDetail.fromJson(Map<String, Object?> json) =>
      _$StudyCafeDetailFromJson(json);
}

List<StudyCafeUsageOption> _usageOptionsFromJson(Object? json) {
  if (json is! List) {
    return const [];
  }
  return json
      .map((Object? item) {
        if (item is! Map) {
          return null;
        }
        return StudyCafeUsageOption.fromJson(
          Map<String, Object?>.from(item),
        );
      })
      .whereType<StudyCafeUsageOption>()
      .toList();
}

List<StudyCafeSeat> _seatsFromLayoutJson(Object? json) {
  if (json is! Map) {
    return const [];
  }

  final rawSeats = json['seats'];
  if (rawSeats is! List) {
    return const [];
  }

  return rawSeats
      .whereType<Map>()
      .map((seat) => StudyCafeSeat.fromJson(Map<String, Object?>.from(seat)))
      .toList();
}

Map<String, dynamic> _seatsToLayoutJson(List<StudyCafeSeat> seats) {
  return {
    'seats': seats.map((seat) => seat.toJson()).toList(),
  };
}

List<StudyCafeLayoutElement> _elementsFromLayoutJson(Object? json) {
  if (json is! Map) {
    return const [];
  }

  final rawElements = json['elements'];
  if (rawElements is! List) {
    return const [];
  }

  return rawElements
      .whereType<Map>()
      .map(
        (element) =>
            StudyCafeLayoutElement.fromJson(Map<String, Object?>.from(element)),
      )
      .toList();
}
