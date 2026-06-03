import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_store_menu_event.freezed.dart';

@freezed
sealed class PartnerStoreMenuEvent with _$PartnerStoreMenuEvent {
  const factory PartnerStoreMenuEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;
  const factory PartnerStoreMenuEvent.pop() = Pop;
}
