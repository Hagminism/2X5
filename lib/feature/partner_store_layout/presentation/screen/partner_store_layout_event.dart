import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_store_layout_event.freezed.dart';

@freezed
sealed class PartnerStoreLayoutEvent with _$PartnerStoreLayoutEvent {
  const factory PartnerStoreLayoutEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;

  const factory PartnerStoreLayoutEvent.pop() = Pop;
}
