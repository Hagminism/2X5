import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_layout_event.freezed.dart';

@freezed
sealed class PartnerStudyCafeLayoutEvent with _$PartnerStudyCafeLayoutEvent {
  const factory PartnerStudyCafeLayoutEvent.showMessage(String message) =
      ShowMessage;

  const factory PartnerStudyCafeLayoutEvent.pop() = Pop;
}
