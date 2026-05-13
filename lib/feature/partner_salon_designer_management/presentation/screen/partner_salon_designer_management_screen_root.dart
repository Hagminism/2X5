import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_screen.dart';
import 'package:capstone_2026/feature/partner_salon_designer_management/presentation/screen/partner_salon_designer_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class PartnerSalonDesignerManagementScreenRoot extends StatefulWidget {
  final PartnerSalonDesignerManagementViewModel viewModel;

  const PartnerSalonDesignerManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonDesignerManagementScreenRoot> createState() =>
      _PartnerSalonDesignerManagementScreenRootState();
}

class _PartnerSalonDesignerManagementScreenRootState
    extends State<PartnerSalonDesignerManagementScreenRoot> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return PartnerSalonDesignerManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonDesignerManagementAction action) {
            switch (action) {
              case PartnerSalonDesignerManagementTapRetry():
              case PartnerSalonDesignerManagementTapAddDesigner():
              case PartnerSalonDesignerManagementTapRemoveDesigner():
              case PartnerSalonDesignerManagementChangeDesignerName():
              case PartnerSalonDesignerManagementChangeDesignerIntroduction():
              case PartnerSalonDesignerManagementRemoveDesignerImage():
              case PartnerSalonDesignerManagementToggleDesignerActive():
              case PartnerSalonDesignerManagementTapSaveDesigners():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonDesignerManagementTapBack():
                context.pop();
                break;
              case PartnerSalonDesignerManagementTapPickDesignerImage(
                :final index,
              ):
                _pickDesignerImage(index);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _pickDesignerImage(int index) async {
    final selected = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selected == null) {
      return;
    }
    await widget.viewModel.updateDesignerImageFromFile(
      index: index,
      filePath: selected.path,
    );
  }
}
