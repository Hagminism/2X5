import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_layout_state.freezed.dart';

@freezed
abstract class PartnerStudyCafeLayoutState with _$PartnerStudyCafeLayoutState {
  const factory PartnerStudyCafeLayoutState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default('') String detailId,
    @Default('') String storeId,
    @Default(<StudyCafeSeat>[]) List<StudyCafeSeat> seats,
    @Default(<StudyCafeLayoutElement>[]) List<StudyCafeLayoutElement> elements,
    @Default(<StudyCafeUsageOption>[]) List<StudyCafeUsageOption> usageOptions,
    @Default(<String>[]) List<String> selectedSeatIds,
    @Default(<String>[]) List<String> selectedElementIds,
    String? selectedElementId,
  }) = _PartnerStudyCafeLayoutState;
}
