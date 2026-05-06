import 'dart:io';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/core/utils/date_format_util.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_state.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReviewHistoryScreen extends StatelessWidget {
  const ReviewHistoryScreen({
    required this.state,
    required this.onEditReview,
    required this.onDeleteReview,
    super.key,
  });

  final ReviewHistoryState state;
  final Future<void> Function(InternalReview review, ReviewWriteResult result)
  onEditReview;
  final Future<void> Function(InternalReview review) onDeleteReview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('리뷰 내역'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.reviews.isEmpty
            ? const _EmptyReviewHistory()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.reviews.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return _ReviewHistoryCard(
                    review: review,
                    onEditReview: onEditReview,
                    onDeleteReview: onDeleteReview,
                  );
                },
              ),
      ),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({
    required this.review,
    required this.onEditReview,
    required this.onDeleteReview,
  });

  final InternalReview review;
  final Future<void> Function(InternalReview review, ReviewWriteResult result)
  onEditReview;
  final Future<void> Function(InternalReview review) onDeleteReview;

  @override
  Widget build(BuildContext context) {
    final storeTitle = review.storeName.isEmpty
        ? review.storeId
        : review.storeName;
    final dateText = formatDotDate(review.createdAt);
    final reviewText = review.content.isEmpty
        ? '작성한 리뷰 내용이 없습니다.'
        : review.content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('${Routes.home}/store/${review.storeId}'),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F111827),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF2F4F7),
                      child: Text(
                        _avatarText(review.userName),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$storeTitle · 사진 ${review.imageUrls.length}장',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<_ReviewMenuAction>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onSelected: (action) async {
                        if (action == _ReviewMenuAction.edit) {
                          await _showEditSheet(context);
                        } else {
                          await _confirmDelete(context);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ReviewMenuAction.edit,
                          child: Text('리뷰 수정'),
                        ),
                        PopupMenuItem(
                          value: _ReviewMenuAction.delete,
                          child: Text('리뷰 삭제'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tileSize = (constraints.maxWidth - 8) / 2;
                    return _ReviewPhotoGrid(
                      imageUrls: review.imageUrls,
                      tileSize: tileSize,
                    );
                  },
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        review.visitPurpose?.trim().isNotEmpty == true
                            ? review.visitPurpose!.trim()
                            : '방문 목적 없음',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      dateText.isEmpty ? '날짜 정보 없음' : dateText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reviewText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _avatarText(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '리';
    }
    return trimmed.characters.first;
  }

  Future<void> _showEditSheet(BuildContext context) async {
    final result = await showModalBottomSheet<ReviewWriteResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => _ReviewEditBottomSheet(review: review),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await onEditReview(review, result);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('리뷰 삭제'),
          content: const Text('작성한 리뷰를 삭제할까요? 이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await onDeleteReview(review);
  }
}

class _ReviewPhotoGrid extends StatelessWidget {
  const _ReviewPhotoGrid({
    required this.imageUrls,
    required this.tileSize,
  });

  final List<String> imageUrls;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return _PhotoPlaceholderTile(size: tileSize);
    }

    final visibleImages = imageUrls.take(2).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: visibleImages
          .map(
            (imageUrl) => _ReviewPhotoTile(
              imageUrl: imageUrl,
              size: tileSize,
            ),
          )
          .toList(),
    );
  }
}

class _ReviewPhotoTile extends StatelessWidget {
  const _ReviewPhotoTile({
    required this.imageUrl,
    required this.size,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _PhotoPlaceholderTile(size: size),
      );
    }

    if (_isFilePath(imageUrl)) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _PhotoPlaceholderTile(size: size),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _PhotoPlaceholderTile(size: size),
    );
  }

  bool _isFilePath(String value) {
    return value.startsWith('/') || RegExp(r'^[A-Za-z]:\\').hasMatch(value);
  }
}

class _PhotoPlaceholderTile extends StatelessWidget {
  const _PhotoPlaceholderTile({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: const Text(
        '등록된 사진이 없습니다',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ReviewEditBottomSheet extends StatefulWidget {
  const _ReviewEditBottomSheet({
    required this.review,
  });

  final InternalReview review;

  @override
  State<_ReviewEditBottomSheet> createState() => _ReviewEditBottomSheetState();
}

class _ReviewEditBottomSheetState extends State<_ReviewEditBottomSheet> {
  late final TextEditingController _contentController;
  late final TextEditingController _visitPurposeController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.review.content);
    _visitPurposeController = TextEditingController(
      text: widget.review.visitPurpose ?? '',
    );
    _rating = widget.review.rating.clamp(1, 5).toDouble();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _visitPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '리뷰 수정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.review.storeName.isEmpty
                    ? widget.review.storeId
                    : widget.review.storeName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const _EditSectionTitle('별점'),
              const SizedBox(height: 10),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    final value = index + 1;
                    return IconButton(
                      onPressed: () =>
                          setState(() => _rating = value.toDouble()),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        value <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 32,
                        color: Colors.amber,
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _EditSectionTitle('방문 목적'),
              const SizedBox(height: 10),
              TextField(
                controller: _visitPurposeController,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '예: 가족 외식, 데이트, 빠른 방문',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _EditSectionTitle('리뷰 내용'),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                minLines: 5,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: '방문 후기를 수정해 주세요.',
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '수정 완료',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('리뷰 내용을 입력해 주세요.')),
        );
      return;
    }

    final visitPurpose = _visitPurposeController.text.trim();
    Navigator.of(context).pop(
      ReviewWriteResult(
        rating: _rating,
        content: content,
        visitTag: visitPurpose.isEmpty ? null : visitPurpose,
      ),
    );
  }
}

class _EditSectionTitle extends StatelessWidget {
  const _EditSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _EmptyReviewHistory extends StatelessWidget {
  const _EmptyReviewHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '아직 작성한 리뷰가 없습니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '방문 후 리뷰를 남기면 이곳에서 작성 내역을 모아볼 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReviewMenuAction {
  edit,
  delete,
}
