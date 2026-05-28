import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_state.freezed.dart';

@freezed
abstract class StoreDetailState with _$StoreDetailState {
  const factory StoreDetailState({
    @Default(0) int selectedTab,
    @Default(false) bool isReviewLoading,
    @Default(<InternalReview>[]) List<InternalReview> reviews,
    StoreStampStatus? stampStatus,
    @Default(emptyStoreDetail) StoreDetail data,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> naverMenus,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> naverReviews,
    @Default(false) bool isNaverDataLoading,
  }) = _StoreDetailState;
}
