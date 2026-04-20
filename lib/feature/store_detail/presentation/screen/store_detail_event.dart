import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail_event.freezed.dart';

@freezed
sealed class StoreDetailEvent with _$StoreDetailEvent {
  const factory StoreDetailEvent.showMessage(String message) = ShowMessage;
}
