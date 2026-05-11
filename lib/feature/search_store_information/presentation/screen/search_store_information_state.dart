import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_store_information_state.freezed.dart';

@freezed
abstract class SearchStoreInformationState with _$SearchStoreInformationState {
  const factory SearchStoreInformationState({
    @Default('') String storeId,
    @Default('') String name,
    @Default('') String subtitle,
    @Default(0) double rating,
    @Default('') String category,
    String? imageUrl,
    @Default(false) bool isBookmarked,
  }) = _SearchStoreInformationState;
}
