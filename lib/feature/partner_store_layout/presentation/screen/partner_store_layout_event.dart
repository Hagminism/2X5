import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_layout_event.freezed.dart';

@freezed
sealed class PartnerStoreLayoutEvent with _$PartnerStoreLayoutEvent {
  const factory PartnerStoreLayoutEvent.showMessage(String message) =
      ShowMessage;

  const factory PartnerStoreLayoutEvent.pop() = Pop;
}
