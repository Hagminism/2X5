import 'package:capstone_2026/feature/address_search/data/model/address_search_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_search_state.freezed.dart';

@freezed
abstract class AddressSearchState with _$AddressSearchState {
  const factory AddressSearchState({
    @Default('') String query,
    @Default(false) bool isLoading,
    @Default(<AddressSearchItem>[]) List<AddressSearchItem> results,
  }) = _AddressSearchState;
}
