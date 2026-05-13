import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_designer_management_state.freezed.dart';

@freezed
abstract class PartnerSalonDesignerManagementState
    with _$PartnerSalonDesignerManagementState {
  const factory PartnerSalonDesignerManagementState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? saveMessage,
    @Default(SalonSettings(storeId: '')) SalonSettings settings,
    @Default([]) List<SalonDesigner> designers,
    @Default([]) List<String?> localDesignerImagePaths,
  }) = _PartnerSalonDesignerManagementState;
}
