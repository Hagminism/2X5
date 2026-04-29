import 'dart:async';

import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_action.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_event.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_screen.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_view_model.dart';
import 'package:capstone_2026/feature/sign_up_partner/component/sign_up_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PartnerOnboardingScreenRoot extends StatefulWidget {
  final PartnerOnboardingViewModel viewModel;

  const PartnerOnboardingScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerOnboardingScreenRoot> createState() =>
      _PartnerOnboardingScreenRootState();
}

class _PartnerOnboardingScreenRootState extends State<PartnerOnboardingScreenRoot> {
  StreamSubscription<PartnerOnboardingEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();
    widget.viewModel.initialize();

    _eventSubscription = widget.viewModel.eventStream.listen((event) async {
      if (!mounted) return;

      switch (event) {
        case ShowMessage():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              duration: const Duration(milliseconds: 1400),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case ShowDatePicker():
          final picked = await showSignUpDatePicker(
            context,
            initialDate: event.initialDate,
          );
          if (!mounted || picked == null) return;
          unawaited(
            widget.viewModel.onAction(
              PartnerOnboardingAction.changeOpenedOn(picked),
            ),
          );
          break;
        case ShowMockGalleryPicker():
          final selected = await _pickImageFromGallery();
          if (!mounted || selected == null) return;
          await widget.viewModel.submitSelectedMockImage(selected);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerOnboardingScreen(
          state: widget.viewModel.state,
          onAction: (action) => widget.viewModel.onAction(action),
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<String?> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return null;
    }
    final pathParts = pickedFile.path.split('/');
    return pathParts.isEmpty ? pickedFile.path : pathParts.last;
  }
}
