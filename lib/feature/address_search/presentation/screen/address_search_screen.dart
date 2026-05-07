import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_action.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AddressSearchScreen extends StatelessWidget {
  final AddressSearchState state;
  final Future<void> Function(AddressSearchAction action) onAction;

  const AddressSearchScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        onAction(AddressSearchAction.changeQuery(value)),
                    onSubmitted: (_) {
                      onAction(const AddressSearchAction.tapSearch());
                    },
                    decoration: InputDecoration(
                      hintText: '도로명, 건물명으로 검색해 주세요',
                      filled: true,
                      fillColor: AppColors.signInTextField,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      onAction(const AddressSearchAction.tapSearch());
                    },
                    child: const Text('검색'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: state.results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.results[index];
                  return Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        onAction(AddressSearchAction.selectResult(item));
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title.isEmpty ? '검색 결과' : item.title,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.address,
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
