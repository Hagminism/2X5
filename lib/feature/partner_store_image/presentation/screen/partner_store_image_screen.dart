import 'package:capstone_2026/feature/partner_store_image/presentation/component/partner_store_image_editor.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStoreImageScreen extends StatelessWidget {
  final PartnerStoreImageState state;
  final void Function(PartnerStoreImageAction action) onAction;

  const PartnerStoreImageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('업장 사진 관리')),
      backgroundColor: AppColors.white,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < state.images.length; i++) ...[
            PartnerStoreImageEditor(
              index: i,
              image: state.images[i],
              onAction: onAction,
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () =>
                onAction(const PartnerStoreImageAction.tapAddImageFromGallery()),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('갤러리에서 사진 추가'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving
                  ? null
                  : () => onAction(const PartnerStoreImageAction.tapSave()),
              child: Text(state.isSaving ? '저장 중...' : '저장'),
            ),
          ),
        ],
      ),
    );
  }
}
