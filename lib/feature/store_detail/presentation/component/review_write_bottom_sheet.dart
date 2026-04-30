import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class ReviewWriteResult {
  const ReviewWriteResult({
    required this.rating,
    required this.content,
    required this.visitTag,
  });

  final double rating;
  final String content;
  final String? visitTag;
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
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _customVisitTagController =
      TextEditingController();
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
                      onPressed: () => setState(() => _rating = value.toDouble()),
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
                  hintText: '음식 맛, 서비스, 분위기, 재방문 의사 등을 자연스럽게 적어주세요.',
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
              Row(
                children: List.generate(3, (index) {
                  final isAddTile = index == 0;
                  return Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: isAddTile
                            ? const Color(0xFFF7F8FA)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        isAddTile
                            ? Icons.add_a_photo_outlined
                            : Icons.image_outlined,
                        color: isAddTile
                            ? AppColors.textSecondary
                            : Colors.white,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              const Text(
                '사진 업로드는 발표 시연에서는 비활성화하고, 실제 연결 시 Storage와 연동할 예정입니다.',
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
      ),
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
