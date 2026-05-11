import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_layout_action.freezed.dart';

@freezed
sealed class PartnerStudyCafeLayoutAction with _$PartnerStudyCafeLayoutAction {
  const factory PartnerStudyCafeLayoutAction.addSeat() = AddSeat;

  const factory PartnerStudyCafeLayoutAction.addElement(
    StudyCafeLayoutElementType type,
  ) = AddElement;

  const factory PartnerStudyCafeLayoutAction.selectSeat(String seatId) =
      SelectSeat;

  const factory PartnerStudyCafeLayoutAction.selectSeats(List<String> seatIds) =
      SelectSeats;

  const factory PartnerStudyCafeLayoutAction.selectElement(String elementId) =
      SelectElement;

  const factory PartnerStudyCafeLayoutAction.removeSelectedSeat() =
      RemoveSelectedSeat;

  const factory PartnerStudyCafeLayoutAction.removeSelectedElement() =
      RemoveSelectedElement;

  const factory PartnerStudyCafeLayoutAction.moveSeat({
    required String seatId,
    required double deltaX,
    required double deltaY,
  }) = MoveSeat;

  const factory PartnerStudyCafeLayoutAction.moveElement({
    required String elementId,
    required double deltaX,
    required double deltaY,
  }) = MoveElement;

  const factory PartnerStudyCafeLayoutAction.changeSelectedSeatLabel(
    String value,
  ) = ChangeSelectedSeatLabel;

  const factory PartnerStudyCafeLayoutAction.toggleSelectedSeatEnabled(
    bool value,
  ) = ToggleSelectedSeatEnabled;

  const factory PartnerStudyCafeLayoutAction.changeSelectedElementLabel(
    String value,
  ) = ChangeSelectedElementLabel;

  const factory PartnerStudyCafeLayoutAction.changeSelectedElementWidth(
    String value,
  ) = ChangeSelectedElementWidth;

  const factory PartnerStudyCafeLayoutAction.changeSelectedElementHeight(
    String value,
  ) = ChangeSelectedElementHeight;

  const factory PartnerStudyCafeLayoutAction.changeSelectedElementRotation(
    String value,
  ) = ChangeSelectedElementRotation;

  const factory PartnerStudyCafeLayoutAction.alignSelectedSeatsHorizontally() =
      AlignSelectedSeatsHorizontally;

  const factory PartnerStudyCafeLayoutAction.alignSelectedSeatsVertically() =
      AlignSelectedSeatsVertically;

  const factory PartnerStudyCafeLayoutAction.addUsageOption() = AddUsageOption;

  const factory PartnerStudyCafeLayoutAction.removeUsageOption(int index) =
      RemoveUsageOption;

  const factory PartnerStudyCafeLayoutAction.changeUsageOptionDuration({
    required int index,
    required String value,
  }) = ChangeUsageOptionDuration;

  const factory PartnerStudyCafeLayoutAction.changeUsageOptionPrice({
    required int index,
    required String value,
  }) = ChangeUsageOptionPrice;

  const factory PartnerStudyCafeLayoutAction.toggleUsageOptionEnabled({
    required int index,
    required bool value,
  }) = ToggleUsageOptionEnabled;

  const factory PartnerStudyCafeLayoutAction.tapSave() = TapSave;
}
