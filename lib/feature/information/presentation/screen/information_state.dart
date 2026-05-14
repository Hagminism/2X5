import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_state.freezed.dart';

@freezed
abstract class InformationState with _$InformationState {
  const factory InformationState({
    @Default('') String storeId,
    @Default('') String name,
    @Default('') String subtitle,
    @Default(0) double rating,
    @Default('') String category,
    String? imageUrl,
    @Default(false) bool isBookmarked,
    @Default([]) List<SalonDesigner> salonDesigners,
  }) = _InformationState;
}
