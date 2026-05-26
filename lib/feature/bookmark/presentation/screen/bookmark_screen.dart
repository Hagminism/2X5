import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_empty_state.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_filter_chips.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_page_header.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_store_card.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({
    required this.viewModel,
    super.key,
  });

  final BookmarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final visibleStores = viewModel.visibleItems;
    final isInitialLoading = viewModel.isLoading && viewModel.items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: isInitialLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: viewModel.loadBookmarks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BookmarkPageHeader(),
                      const SizedBox(height: 14),
                      BookmarkFilterChips(
                        filters: BookmarkViewModel.filters,
                        selectedFilter: viewModel.selectedFilter,
                        onFilterSelected: viewModel.selectFilter,
                      ),
                      const SizedBox(height: 16),
                      if (viewModel.errorMessage != null) ...[
                        const Text(
                          '목록을 불러오지 못했습니다.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: viewModel.loadBookmarks,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          child: const Text('다시 시도'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (visibleStores.isEmpty &&
                          viewModel.errorMessage == null)
                        BookmarkEmptyState(
                          onExploreTap: () => context.go(Routes.home),
                        )
                      else
                        Column(
                          children: visibleStores.map((item) {
                            final categoryLabel =
                                StoreCategory.fromDbValue(item.category)
                                    ?.displayName ??
                                item.category;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BookmarkStoreCard(
                                name: item.name,
                                category: categoryLabel,
                                subtitle: viewModel.subtitleFor(item),
                                rating: item.rating,
                                reviewCount: item.reviewCount,
                                imageUrl: item.imageUrl,
                                onTap: () async {
                                  await context.pushNamed(
                                    Routes.bookmarkInformationName,
                                    pathParameters: {
                                      'storeId': item.storeId,
                                    },
                                  );
                                  if (context.mounted) {
                                    await viewModel.loadBookmarks();
                                  }
                                },
                                onBookmarkTap: () async {
                                  try {
                                    await viewModel.removeBookmark(
                                      item.storeId,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '저장 목록에서 제거했습니다.',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      );
                                  } catch (_) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            '제거에 실패했습니다.',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      );
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}