import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_layout_action.freezed.dart';

@freezed
sealed class PartnerStoreLayoutAction with _$PartnerStoreLayoutAction {
  const factory PartnerStoreLayoutAction.addSeat() = AddSeat;

  const factory PartnerStoreLayoutAction.addElement(
    StudyCafeLayoutElementType type,
  ) = AddElement;

  const factory PartnerStoreLayoutAction.selectSeat(String seatId) = SelectSeat;

  const factory PartnerStoreLayoutAction.selectSeats(List<String> seatIds) = SelectSeats;

  const factory PartnerStoreLayoutAction.selectElement(String elementId) = SelectElement;

  const factory PartnerStoreLayoutAction.selectElements(
    List<String> elementIds,
  ) = SelectElements;

  const factory PartnerStoreLayoutAction.removeSelectedSeat() = RemoveSelectedSeat;

  const factory PartnerStoreLayoutAction.removeSelectedElement() = RemoveSelectedElement;

  const factory PartnerStoreLayoutAction.moveSeat({
    required String seatId,
    required double deltaX,
    required double deltaY,
  }) = MoveSeat;

  const factory PartnerStoreLayoutAction.moveElement({
    required String elementId,
    required double deltaX,
    required double deltaY,
  }) = MoveElement;

  const factory PartnerStoreLayoutAction.changeSelectedSeatLabel(
    String value,
  ) = ChangeSelectedSeatLabel;

  const factory PartnerStoreLayoutAction.toggleSelectedSeatEnabled(
    bool value,
  ) = ToggleSelectedSeatEnabled;

  const factory PartnerStoreLayoutAction.changeSelectedElementLabel(
    String value,
  ) = ChangeSelectedElementLabel;

  const factory PartnerStoreLayoutAction.changeSelectedElementWidth(
    String value,
  ) = ChangeSelectedElementWidth;

  const factory PartnerStoreLayoutAction.changeSelectedElementHeight(
    String value,
  ) = ChangeSelectedElementHeight;

  const factory PartnerStoreLayoutAction.changeSelectedElementRotation(
    String value,
  ) = ChangeSelectedElementRotation;

  const factory PartnerStoreLayoutAction.alignSelectedSeatsHorizontally() = AlignSelectedSeatsHorizontally;

  const factory PartnerStoreLayoutAction.alignSelectedSeatsVertically() = AlignSelectedSeatsVertically;

  const factory PartnerStoreLayoutAction.duplicateSelectedSeats() = DuplicateSelectedSeats;

  const factory PartnerStoreLayoutAction.tapSave() = TapSave;
}
