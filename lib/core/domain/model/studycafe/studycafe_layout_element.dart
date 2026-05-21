import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_layout_element.freezed.dart';
part 'studycafe_layout_element.g.dart';

@freezed
abstract class StudyCafeLayoutElement with _$StudyCafeLayoutElement {
  const factory StudyCafeLayoutElement({
    @JsonKey(name: 'element_id') required String elementId,
    required StudyCafeLayoutElementType type,
    required String label,
    required double x,
    required double y,
    @Default(0.2) double width,
    @Default(0.08) double height,
    @Default(0) double rotation,
  }) = _StudyCafeLayoutElement;

  factory StudyCafeLayoutElement.fromJson(Map<String, Object?> json) =>
      _$StudyCafeLayoutElementFromJson(json);
}
