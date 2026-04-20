import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_action.freezed.dart';

@freezed
sealed class StoreDetailAction with _$StoreDetailAction {
  const factory StoreDetailAction.initialize(String storeId) = Initialize;

  const factory StoreDetailAction.tapBack() = TapBack;

  const factory StoreDetailAction.tapHome() = TapHome;

  const factory StoreDetailAction.tapSearch() = TapSearch;

  const factory StoreDetailAction.tapTopBookmark() = TapTopBookmark;

  const factory StoreDetailAction.tapShare() = TapShare;

  const factory StoreDetailAction.tapInfoCall() = TapInfoCall;

  const factory StoreDetailAction.tapBottomBookmark() = TapBottomBookmark;

  const factory StoreDetailAction.tapBottomCall() = TapBottomCall;

  const factory StoreDetailAction.tapReserve() = TapReserve;

  const factory StoreDetailAction.tapTab(int index) = TapTab;
}
