import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/data/dto/partner_studycafe_layout_selected_layout_item_dto.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/domain/model/partner_studycafe_layout_item_type.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/domain/model/partner_studycafe_layout_selected_layout_item.dart';

extension PartnerStudyCafeLayoutSelectedLayoutItemDtoMapper
    on PartnerStudyCafeLayoutSelectedLayoutItemDto {
  PartnerStudyCafeLayoutSelectedLayoutItem toModel() {
    return PartnerStudyCafeLayoutSelectedLayoutItem(
      id: id ?? '',
      x: x ?? 0,
      y: y ?? 0,
      type: _parseItemType(type),
      seat: seat == null
          ? null
          : StudyCafeSeat.fromJson(
              Map<String, Object?>.from(seat!),
            ),
      element: element == null
          ? null
          : StudyCafeLayoutElement.fromJson(
              Map<String, Object?>.from(element!),
            ),
    );
  }

  PartnerStudyCafeLayoutItemType _parseItemType(String? raw) {
    return PartnerStudyCafeLayoutItemType.values.firstWhere(
      (PartnerStudyCafeLayoutItemType e) => e.name == raw,
      orElse: () => PartnerStudyCafeLayoutItemType.seat,
    );
  }
}

extension PartnerStudyCafeLayoutSelectedLayoutItemToDtoMapper
    on PartnerStudyCafeLayoutSelectedLayoutItem {
  PartnerStudyCafeLayoutSelectedLayoutItemDto toDto() {
    return PartnerStudyCafeLayoutSelectedLayoutItemDto(
      id: id,
      x: x,
      y: y,
      type: type.name,
      seat: seat?.toJson(),
      element: element?.toJson(),
    );
  }
}
