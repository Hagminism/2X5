import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_store_layout_state.freezed.dart';

@freezed
abstract class PartnerStoreLayoutState with _$PartnerStoreLayoutState {
  const factory PartnerStoreLayoutState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default('') String detailId,
    @Default('') String storeId,
    @Default(<StudyCafeSeat>[]) List<StudyCafeSeat> seats,
    @Default(<StudyCafeLayoutElement>[]) List<StudyCafeLayoutElement> elements,
    @Default(<String>[]) List<String> selectedSeatIds,
    @Default(<String>[]) List<String> selectedElementIds,
    String? selectedElementId,
  }) = _PartnerStoreLayoutState;
}
