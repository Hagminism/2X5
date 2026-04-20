import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_action.freezed.dart';

@freezed
sealed class StoreDetailAction with _$StoreDetailAction {
  const factory StoreDetailAction.tapBack() = TapBack;

  const factory StoreDetailAction.tapHome() = TapHome;

  const factory StoreDetailAction.tapSearch() = TapSearch;

  const factory StoreDetailAction.tapBookmark() = TapBookmark;

  const factory StoreDetailAction.tapShare() = TapShare;

  const factory StoreDetailAction.tapCall() = TapCall;

  const factory StoreDetailAction.tapReserve() = TapReserve;

  const factory StoreDetailAction.tapNaverReviewButton() = TapNaverReviewButton;

  const factory StoreDetailAction.tapGoogleReviewButton() = TapGoogleReviewButton;

  const factory StoreDetailAction.moveTab(int index) = MoveTab;
}
