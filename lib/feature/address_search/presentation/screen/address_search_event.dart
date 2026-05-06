import 'package:capstone_2026/feature/address_search/domain/model/address_search_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_search_event.freezed.dart';

@freezed
sealed class AddressSearchEvent with _$AddressSearchEvent {
  const factory AddressSearchEvent.showMessage(String message) = ShowMessage;
  const factory AddressSearchEvent.popWithResult(AddressSearchResult result) =
      PopWithResult;
}
