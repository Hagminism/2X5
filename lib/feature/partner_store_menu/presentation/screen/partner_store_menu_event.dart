import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_menu_event.freezed.dart';

@freezed
sealed class PartnerStoreMenuEvent with _$PartnerStoreMenuEvent {
  const factory PartnerStoreMenuEvent.showMessage(String message) = ShowMessage;
  const factory PartnerStoreMenuEvent.pop() = Pop;
}
