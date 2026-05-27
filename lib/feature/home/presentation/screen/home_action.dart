import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_action.freezed.dart';

@freezed
sealed class HomeAction with _$HomeAction {
  const factory HomeAction.loadHomeData() = LoadHomeData;

  const factory HomeAction.retryLoadHomeData() = RetryLoadHomeData;

  const factory HomeAction.loadMoreStores() = LoadMoreStores;

  const factory HomeAction.showSoonMessage(String message) = ShowSoonMessage;

  const factory HomeAction.tapBookmark(String storeId) = TapHomeBookmark;

  const factory HomeAction.selectCategory(StoreCategory? category) =
      SelectCategory;
}