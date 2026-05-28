import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Notice {
  final String title;
  final String date;
  final String content;

  const _Notice({
    required this.title,
    required this.date,
    required this.content,
  });
}

const _notices = [
  _Notice(
    title: '20260528 업데이트',
    date: '2026.05.28',
    content:
        '• 지도 마커 클러스터링 기능이 추가되었습니다.\n'
        '• 카테고리별로 마커가 구분되어 표시됩니다.\n'
        '• 홈 화면 UI가 개선되었습니다.\n'
        '• 일부 버그가 수정되었습니다.',
  ),
  _Notice(
    title: '20260523 업데이트',
    date: '2026.05.23',
    content:
        '• 북마크 기능이 추가되었습니다.\n'
        '• 가게 상세 페이지에서 리뷰를 작성할 수 있습니다.\n'
        '• 스탬프 시스템이 도입되었습니다.\n'
        '• 앱 성능이 개선되었습니다.',
  ),
  _Notice(
    title: '서비스 오픈 안내',
    date: '2026.05.01',
    content:
        '2X5 서비스가 정식 오픈되었습니다.\n\n'
        '한성대학교 주변 업장 예약 및 정보 조회 서비스를 이용해보세요.\n\n'
        '더 나은 서비스를 위해 지속적으로 업데이트할 예정입니다.\n'
        '이용해 주셔서 감사합니다.',
  ),
];

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '공지사항',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: _notices.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final notice = _notices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            title: Text(
              notice.title,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notice.date,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _NoticeDetailScreen(notice: notice),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoticeDetailScreen extends StatelessWidget {
  final _Notice notice;

  const _NoticeDetailScreen({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '공지사항',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notice.date,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              notice.content,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
