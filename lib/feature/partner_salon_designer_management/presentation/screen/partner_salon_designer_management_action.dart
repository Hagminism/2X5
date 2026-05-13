import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_salon_designer_management_action.freezed.dart';

@freezed
sealed class PartnerSalonDesignerManagementAction
    with _$PartnerSalonDesignerManagementAction {
  const factory PartnerSalonDesignerManagementAction.tapBack() =
      PartnerSalonDesignerManagementTapBack;

  const factory PartnerSalonDesignerManagementAction.tapRetry() =
      PartnerSalonDesignerManagementTapRetry;

  const factory PartnerSalonDesignerManagementAction.tapAddDesigner() =
      PartnerSalonDesignerManagementTapAddDesigner;

  const factory PartnerSalonDesignerManagementAction.tapRemoveDesigner(
    int index,
  ) = PartnerSalonDesignerManagementTapRemoveDesigner;

  const factory PartnerSalonDesignerManagementAction.changeDesignerName({
    required int index,
    required String value,
  }) = PartnerSalonDesignerManagementChangeDesignerName;

  const factory PartnerSalonDesignerManagementAction.changeDesignerIntroduction({
    required int index,
    required String value,
  }) = PartnerSalonDesignerManagementChangeDesignerIntroduction;

  const factory PartnerSalonDesignerManagementAction.tapPickDesignerImage(
    int index,
  ) = PartnerSalonDesignerManagementTapPickDesignerImage;

  const factory PartnerSalonDesignerManagementAction.removeDesignerImage(
    int index,
  ) = PartnerSalonDesignerManagementRemoveDesignerImage;

  const factory PartnerSalonDesignerManagementAction.toggleDesignerActive({
    required int index,
    required bool value,
  }) = PartnerSalonDesignerManagementToggleDesignerActive;

  const factory PartnerSalonDesignerManagementAction.tapSaveDesigners() =
      PartnerSalonDesignerManagementTapSaveDesigners;
}
