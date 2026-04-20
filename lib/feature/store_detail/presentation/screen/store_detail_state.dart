import 'package:capstone_2026/feature/store_detail/data/mocks/store_detail_mock_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_state.freezed.dart';

@freezed
abstract class StoreDetailState with _$StoreDetailState {
  const factory StoreDetailState({
    @Default('') String storeId,
    @Default(0) int selectedTab,
    @Default(defaultStoreData) StoreDetailData data,
  }) = _StoreDetailState;
}
