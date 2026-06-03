import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'store_detail_event.freezed.dart';

@freezed
sealed class StoreDetailEvent with _$StoreDetailEvent {
  const factory StoreDetailEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;

  const factory StoreDetailEvent.openNaverReview({
    required Uri webUri,
    Uri? appUri,
  }) = OpenNaverReview;

  const factory StoreDetailEvent.openGoogleMap(Uri webUri) = OpenGoogleMap;
}
