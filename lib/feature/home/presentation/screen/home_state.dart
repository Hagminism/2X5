import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(<HomeStoreItem>[]) List<HomeStoreItem> recommendedStores,
  }) = _HomeState;
}
