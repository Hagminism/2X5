import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

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
  final List<String> _visitTags = const ['혼밥', '데이트', '모임', '가족 외식', '빠른 방문'];

  double _rating = 4;
  String? _selectedTag;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                '이용 완료된 예약 건에 한해 리뷰를 남길 수 있도록 추후 연결될 예정입니다.',
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
                        value <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
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
                children: _visitTags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedTag = tag),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withValues(alpha: 0.14),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const _SectionTitle('리뷰 내용'),
              const SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                minLines: 5,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: '음식 맛, 서비스, 분위기, 재방문 의사 등을 자유롭게 적어주세요.',
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
                        color: isAddTile ? const Color(0xFFF7F8FA) : AppColors.border,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isAddTile ? AppColors.border : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        isAddTile ? Icons.add_a_photo_outlined : Icons.image_outlined,
                        color: isAddTile ? AppColors.textSecondary : Colors.white,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              const Text(
                '사진 업로드는 추후 Storage 연결 시 활성화됩니다.',
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
                    Icon(Icons.card_giftcard_outlined, color: Color(0xFFD99A00), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '리뷰 작성이 실제로 연결되면 스탬프 적립과 함께 마이페이지 리뷰 내역에서도 수정·삭제가 가능하도록 확장할 예정입니다.',
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
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('리뷰 저장 기능은 추후 Supabase 테이블 연결 후 활성화됩니다.'),
                        ),
                      );
                  },
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
