import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_store_information_state.freezed.dart';

@freezed
abstract class MapStoreInformationState with _$MapStoreInformationState {
  const factory MapStoreInformationState({
    @Default('') String storeId,
    @Default('') String name,
    @Default('') String subtitle,
    @Default(0) double rating,
    @Default('') String category,
    String? imageUrl,
    @Default(false) bool isBookmarked,
  }) = _MapStoreInformationState;
}
