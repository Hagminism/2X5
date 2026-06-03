import 'package:capstone_2026/feature/address_search/domain/model/address_search_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'address_search_event.freezed.dart';

@freezed
sealed class AddressSearchEvent with _$AddressSearchEvent {
  const factory AddressSearchEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;
  const factory AddressSearchEvent.popWithResult(AddressSearchResult result) =
      PopWithResult;
}
