import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_menu_state.freezed.dart';

@freezed
abstract class PartnerStoreMenuState with _$PartnerStoreMenuState {
  const factory PartnerStoreMenuState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default(<StoreMenu>[]) List<StoreMenu> menus,
  }) = _PartnerStoreMenuState;
}
