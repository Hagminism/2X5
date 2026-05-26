import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(<HomeStoreItem>[]) List<HomeStoreItem> recommendedStores,
    StoreCategory? selectedCategory,
    /// GPS 기준 거리순 페이징 vs 서버 range 페이징.
    @Default(false) bool usesDistancePaging,
    /// [recommendedStores]에 노출된 누적 개수 (풀 대비 hasMore 계산).
    @Default(0) int visibleStoreCount,
    @Default(<String>{}) Set<String> bookmarkedStoreIds,
    double? userLatitude,
    double? userLongitude,
  }) = _HomeState;
}
