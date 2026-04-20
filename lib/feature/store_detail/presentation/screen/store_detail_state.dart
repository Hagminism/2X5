import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_state.freezed.dart';

@freezed
abstract class StoreDetailState with _$StoreDetailState {
  const factory StoreDetailState({
    @Default(0) int selectedTab,
    @Default(emptyStoreDetail) StoreDetail data,
  }) = _StoreDetailState;
}
