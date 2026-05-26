import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class MyProfileCard extends StatelessWidget {
  final String? name;
  final String? email;
  final String? photoUrl;
  final void Function() onTap;

  const MyProfileCard({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.onTap,
    super.key,
  });

  static const Color _cardBackground = Color(0xFF1A1A2E);
  static const Color _onCardMuted = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? '사용자';
    final firstLetter = displayName.isNotEmpty ? displayName[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email ?? '',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: _onCardMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _onCardMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
