import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StoreHomeTab extends StatelessWidget {
  const StoreHomeTab({
    super.key,
    required this.address,
    required this.displayPhone,
    required this.menus,
    required this.onViewMoreMenus,
  });

  final String address;
  /// 뷰모델 `displayPhone` (`stores.phone` 우선, 없으면 `contact`).
  final String displayPhone;
  final List<StoreMenu> menus;
  final VoidCallback onViewMoreMenus;

  static const String _dummyHours = '브레이크타임 · 17:00에 영업 시작';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _InfoTile(
          icon: Icons.location_on_outlined,
          child: Text(
            address.trim().isEmpty ? '주소 정보 없음' : address.trim(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _InfoTile(
          icon: Icons.schedule_rounded,
          child: const Text(
            _dummyHours,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _InfoTile(
          icon: Icons.phone_outlined,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayPhone.trim().isEmpty
                      ? '전화번호 없음'
                      : displayPhone.trim(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (displayPhone.trim().isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: displayPhone.trim()),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('전화번호를 복사했습니다.')),
                      );
                    }
                  },
                  child: const Text(
                    '복사',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 8, color: const Color(0xFFF3F4F6)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '메뉴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${menus.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: menus.isEmpty
              ? const Center(
                  child: Text(
                    '등록된 메뉴가 없습니다.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: menus.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _HomeMenuCard(menu: menus[index]);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewMoreMenus,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '메뉴 더보기  >',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _HomeMenuCard extends StatelessWidget {
  const _HomeMenuCard({required this.menu});

  final StoreMenu menu;

  @override
  Widget build(BuildContext context) {
    final url = menu.imageUrl.trim();
    final priceFmt = NumberFormat('#,###', 'ko_KR');

    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: url.isEmpty
                  ? const ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            menu.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${priceFmt.format(menu.price)}원',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}