import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_studycafe_layout_event.freezed.dart';

@freezed
sealed class PartnerStudyCafeLayoutEvent with _$PartnerStudyCafeLayoutEvent {
  const factory PartnerStudyCafeLayoutEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) =
      ShowMessage;

  const factory PartnerStudyCafeLayoutEvent.pop() = Pop;
}
