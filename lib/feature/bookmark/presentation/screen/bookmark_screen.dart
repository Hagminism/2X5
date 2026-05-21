import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_empty_state.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_filter_chips.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_page_header.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_store_card.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isInitialLoading
            ? const Center(child: CircularProgressIndicator())
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
                        Text(
                          '목록을 불러오지 못했습니다.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: viewModel.loadBookmarks,
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
                                reviewCount: 0,
                                onTap: () async {
                                  await context.pushNamed(
                                    'bookmark_information',
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
                                          content: Text('제거에 실패했습니다.'),
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