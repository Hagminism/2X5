import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_screen.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_event.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'dart:async';

class PartnerStoreImageScreenRoot extends StatefulWidget {
  final PartnerStoreImageViewModel viewModel;

  const PartnerStoreImageScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreImageScreenRoot> createState() =>
      _PartnerStoreImageScreenRootState();
}

class _PartnerStoreImageScreenRootState
    extends State<PartnerStoreImageScreenRoot> {
  final ImagePicker _imagePicker = ImagePicker();
  StreamSubscription<PartnerStoreImageEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    _eventSubscription = widget.viewModel.eventStream.listen((event) async {
      if (!mounted) return;
      switch (event) {
        case ShowMessage(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case OpenGallery():
          await _pickImageFromGallery();
          break;
        case Pop():
          context.pop();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStoreImageScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapAddImageFromGallery():
              case RemoveStoreImage():
              case ChangeStoreImageCaption():
              case SelectCoverImage():
              case TapSave():
                widget.viewModel.onAction(action);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final selected = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selected == null) {
      return;
    }
    await widget.viewModel.addImageByFilePath(selected.path);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
