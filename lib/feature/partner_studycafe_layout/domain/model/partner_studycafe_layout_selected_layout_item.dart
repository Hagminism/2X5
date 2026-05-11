import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/domain/model/partner_studycafe_layout_item_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_layout_selected_layout_item.freezed.dart';

@freezed
abstract class PartnerStudyCafeLayoutSelectedLayoutItem
    with _$PartnerStudyCafeLayoutSelectedLayoutItem {
  const factory PartnerStudyCafeLayoutSelectedLayoutItem({
    required String id,
    required double x,
    required double y,
    required PartnerStudyCafeLayoutItemType type,
    StudyCafeSeat? seat,
    StudyCafeLayoutElement? element,
  }) = _PartnerStudyCafeLayoutSelectedLayoutItem;
}
