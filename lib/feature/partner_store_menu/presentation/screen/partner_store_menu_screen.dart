import 'package:capstone_2026/feature/partner_store_menu/presentation/component/partner_store_menu_editor.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStoreMenuScreen extends StatelessWidget {
  final PartnerStoreMenuState state;
  final void Function(PartnerStoreMenuAction action) onAction;

  const PartnerStoreMenuScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메뉴 관리')),
      backgroundColor: AppColors.white,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < state.menus.length; i++) ...[
            PartnerStoreMenuEditor(
              index: i,
              menu: state.menus[i],
              onAction: onAction,
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: () => onAction(const PartnerStoreMenuAction.addMenu()),
            icon: const Icon(Icons.add),
            label: const Text('메뉴 추가'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving
                  ? null
                  : () => onAction(const PartnerStoreMenuAction.tapSave()),
              child: Text(state.isSaving ? '저장 중...' : '저장'),
            ),
          ),
        ],
      ),
    );
  }
}
