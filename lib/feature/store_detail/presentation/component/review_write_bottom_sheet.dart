import 'dart:io';

import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewWriteResult {
  const ReviewWriteResult({
    required this.rating,
    required this.content,
    required this.visitTag,
    required this.imagePaths,
  });

  final double rating;
  final String content;
  final String? visitTag;
  final List<String> imagePaths;
}

class ReviewWriteBottomSheet extends StatefulWidget {
  const ReviewWriteBottomSheet({
    required this.storeName,
    super.key,
  });

  final String storeName;

  @override
  State<ReviewWriteBottomSheet> createState() => _ReviewWriteBottomSheetState();
}

class _ReviewWriteBottomSheetState extends State<ReviewWriteBottomSheet> {
  static const int _maxImageCount = 3;

  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _customVisitTagController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _visitTags = const [
    '혼밥',
    '데이트',
    '모임',
    '가족 외식',
    '빠른 방문',
  ];

  double _rating = 4;
  String? _selectedTag;
  String? _customVisitTag;
  bool _isCustomVisitTagEditing = false;
  bool _isPickingImages = false;
  List<String> _selectedImagePaths = const [];

  @override
  void dispose() {
    _reviewController.dispose();
    _customVisitTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustomSelected =
        _customVisitTag != null && _selectedTag == _customVisitTag;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
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
              Text(
                '${widget.storeName} 리뷰 작성',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '시연용 mock 리뷰입니다. 작성하면 바로 화면에 반영되어 실제 등록된 것처럼 보입니다.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('별점'),
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
                        color: Colors.amber,
                        size: 32,
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
              const SizedBox(height: 20),
              const _SectionTitle('방문 목적'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._visitTags.map((tag) {
                    final isSelected = _selectedTag == tag;
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedTag = tag;
                          _isCustomVisitTagEditing = false;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.14),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    );
                  }),
                  ActionChip(
                    label: Text(_customVisitTag ?? '직접 입력'),
                    onPressed: () {
                      setState(() {
                        _isCustomVisitTagEditing = true;
                        _customVisitTagController.text = _customVisitTag ?? '';
                      });
                    },
                    backgroundColor: isCustomSelected
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.white,
                    labelStyle: TextStyle(
                      color: isCustomSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isCustomSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isCustomSelected
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  ),
                ],
              ),
              if (_isCustomVisitTagEditing) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customVisitTagController,
                  autofocus: true,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: '예: 가족 생일, 회식, 부모님과 방문',
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _isCustomVisitTagEditing = false;
                          _customVisitTagController.clear();
                        });
                      },
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _applyCustomVisitTag,
                      child: const Text('적용'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const _SectionTitle('리뷰 내용'),
              const SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                minLines: 5,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: '음식 맛, 서비스, 분위기, 이용 경험을 자연스럽게 적어주세요.',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
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
              const _SectionTitle('사진 첨부'),
              const SizedBox(height: 10),
              _ReviewImagePickerSection(
                imagePaths: _selectedImagePaths,
                isPickingImages: _isPickingImages,
                onTapAdd: _pickImages,
                onTapRemove: _removeImageAt,
              ),
              const SizedBox(height: 10),
              const Text(
                '지금은 mock 방식으로 사진 경로만 함께 저장합니다. 추후에는 Storage 업로드로 연결할 예정입니다.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      color: Color(0xFFD99A00),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '실제 서비스 단계에서는 리뷰 작성 후 스탬프 적립, 마이페이지 수정/삭제 흐름까지 확장할 예정입니다.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                    '리뷰 등록',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCustomVisitTag() {
    final value = _customVisitTagController.text.trim();
    if (value.isEmpty) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isCustomVisitTagEditing = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _customVisitTag = value;
      _selectedTag = value;
      _isCustomVisitTagEditing = false;
    });
  }

  Future<void> _pickImages() async {
    if (_isPickingImages) {
      return;
    }

    setState(() {
      _isPickingImages = true;
    });

    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);
      if (!mounted || pickedFiles.isEmpty) {
        return;
      }

      final remainingCount = _maxImageCount - _selectedImagePaths.length;
      final nextImages = pickedFiles
          .map((file) => file.path)
          .where((path) => path.isNotEmpty)
          .take(remainingCount)
          .toList();

      if (nextImages.isEmpty) {
        return;
      }

      setState(() {
        _selectedImagePaths = [..._selectedImagePaths, ...nextImages];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('사진을 불러오는 중 오류가 발생했습니다.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImages = false;
        });
      }
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      _selectedImagePaths = List<String>.from(_selectedImagePaths)
        ..removeAt(index);
    });
  }

  void _submit() {
    final content = _reviewController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('리뷰 내용을 입력해 주세요.')),
        );
      return;
    }

    Navigator.of(context).pop(
      ReviewWriteResult(
        rating: _rating,
        content: content,
        visitTag: _selectedTag,
        imagePaths: _selectedImagePaths,
      ),
    );
  }
}

class _ReviewImagePickerSection extends StatelessWidget {
  const _ReviewImagePickerSection({
    required this.imagePaths,
    required this.isPickingImages,
    required this.onTapAdd,
    required this.onTapRemove,
  });

  final List<String> imagePaths;
  final bool isPickingImages;
  final Future<void> Function() onTapAdd;
  final void Function(int index) onTapRemove;

  @override
  Widget build(BuildContext context) {
    final canAddMore = imagePaths.length < _ReviewWriteBottomSheetState._maxImageCount;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (canAddMore)
          _AddImageTile(
            isLoading: isPickingImages,
            onTap: onTapAdd,
          ),
        ...imagePaths.asMap().entries.map((entry) {
          return _SelectedImageTile(
            imagePath: entry.value,
            onTapRemove: () => onTapRemove(entry.key),
          );
        }),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: isLoading
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : const Icon(
                Icons.add_a_photo_outlined,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }
}

class _SelectedImageTile extends StatelessWidget {
  const _SelectedImageTile({
    required this.imagePath,
    required this.onTapRemove,
  });

  final String imagePath;
  final VoidCallback onTapRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 84,
            height: 84,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.border,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: onTapRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

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
