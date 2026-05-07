import 'package:capstone_2026/feature/address_search/data/model/address_search_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_search_action.freezed.dart';

@freezed
sealed class AddressSearchAction with _$AddressSearchAction {
  const factory AddressSearchAction.changeQuery(String query) = ChangeQuery;
  const factory AddressSearchAction.tapSearch() = TapSearch;
  const factory AddressSearchAction.selectResult(AddressSearchItem item) =
      SelectResult;
}
