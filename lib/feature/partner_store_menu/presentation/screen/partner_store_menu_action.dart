import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_menu_action.freezed.dart';

@freezed
sealed class PartnerStoreMenuAction with _$PartnerStoreMenuAction {
  const factory PartnerStoreMenuAction.addMenu() = AddMenu;
  const factory PartnerStoreMenuAction.removeMenu(int index) = RemoveMenu;
  const factory PartnerStoreMenuAction.changeMenuName({
    required int index,
    required String value,
  }) = ChangeMenuName;
  const factory PartnerStoreMenuAction.changeMenuPrice({
    required int index,
    required String value,
  }) = ChangeMenuPrice;
  const factory PartnerStoreMenuAction.changeMenuDescription({
    required int index,
    required String value,
  }) = ChangeMenuDescription;
  const factory PartnerStoreMenuAction.tapPickMenuImage(int index) =
      TapPickMenuImage;
  const factory PartnerStoreMenuAction.removeMenuImage(int index) =
      RemoveMenuImage;
  const factory PartnerStoreMenuAction.toggleMenuAvailable({
    required int index,
    required bool value,
  }) = ToggleMenuAvailable;
  const factory PartnerStoreMenuAction.tapSave() = TapSave;
}
