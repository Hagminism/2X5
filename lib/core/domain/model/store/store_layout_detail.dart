import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_layout_detail.freezed.dart';
part 'store_layout_detail.g.dart';

@freezed
abstract class StoreLayoutDetail with _$StoreLayoutDetail {
  const factory StoreLayoutDetail({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @Default(<StudyCafeLayoutElement>[]) List<StudyCafeLayoutElement> elements,
    @Default(<StudyCafeSeat>[]) List<StudyCafeSeat> seats,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _StoreLayoutDetail;

  factory StoreLayoutDetail.fromJson(Map<String, Object?> json) =>
      _$StoreLayoutDetailFromJson(json);
}
