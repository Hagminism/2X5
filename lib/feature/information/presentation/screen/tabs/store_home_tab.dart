import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/util/store_operating_hours_display.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class StoreHomeTab extends StatefulWidget {
  const StoreHomeTab({
    super.key,
    required this.address,
    required this.displayPhone,
    required this.operatingHours,
    required this.description,
    required this.menus,
    required this.onViewMoreMenus,
    required this.showMenuSection,
  });

  final String address;
  final String displayPhone;
  final String description;
  final Map<String, dynamic> operatingHours;
  final List<StoreMenu> menus;
  final VoidCallback onViewMoreMenus;
  final bool showMenuSection;

  @override
  State<StoreHomeTab> createState() => _StoreHomeTabState();
}

class _StoreHomeTabState extends State<StoreHomeTab> {
  bool get _hasDescription => widget.description.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final address = widget.address;
    final displayPhone = widget.displayPhone;
    final description = widget.description;
    final operatingHours = widget.operatingHours;
    final menus = widget.menus;
    final onViewMoreMenus = widget.onViewMoreMenus;
    final showMenuSection = widget.showMenuSection;

    final descriptionBlock = _hasDescription
        ? _StoreDescriptionBlock(description: description.trim())
        : null;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.location_on_outlined,
                child: Text(
                  address.trim().isEmpty ? '주소 정보 없음' : address.trim(),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: -0.1,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _OperatingHoursSection(operatingHours: operatingHours),
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
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (displayPhone.trim().isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: displayPhone.trim()),
                            );
                            if (context.mounted) {
                              AppSnackBar.showSuccess(
                                context,
                                '전화번호를 복사했습니다.',
                              );
                            }
                          },
                          child: const Text(
                            '복사',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!showMenuSection && descriptionBlock != null) ...[
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  color: const Color(0xFFF3F4F6),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: descriptionBlock,
                ),
              ],
            ],
          ),
        ),
        if (showMenuSection) ...[
          Container(height: 8, color: const Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '메뉴',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${menus.length}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
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
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: menus.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _HomeMenuCard(menu: menus[index]);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (showMenuSection && descriptionBlock != null) ...[
          Container(height: 8, color: const Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: descriptionBlock,
          ),
        ],
      ],
    );
  }
}

class _OperatingHoursSection extends StatefulWidget {
  const _OperatingHoursSection({required this.operatingHours});

  final Map<String, dynamic> operatingHours;

  @override
  State<_OperatingHoursSection> createState() => _OperatingHoursSectionState();
}

class _OperatingHoursSectionState extends State<_OperatingHoursSection> {
  bool _isExpanded = false;

  static const TextStyle _summaryStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle _dayStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle _subStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final summary = resolveOperatingHoursSummary(widget.operatingHours);
    final summaryText = summary.isEmpty ? '영업시간 정보 없음' : summary;
    final weeklyLines = buildWeeklyOperatingHoursLines(widget.operatingHours);
    final canExpand = weeklyLines.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(summaryText, style: _summaryStyle),
              const SizedBox(width: 4),
              if (canExpand)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        size: 28,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isExpanded && canExpand)
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in weeklyLines) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(line.dayLabel, style: _dayStyle),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.hoursText, style: _dayStyle),
                            if (line.subText != null) ...[
                              const SizedBox(height: 2),
                              Text(line.subText!, style: _subStyle),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _StoreDescriptionBlock extends StatelessWidget {
  const _StoreDescriptionBlock({required this.description});

  final String description;

  static const TextStyle _titleStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8ECF0)),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Text('매장 소개', style: _titleStyle),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: _bodyStyle),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.child,
  });

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: child),
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
                      errorBuilder: (_, _, _) => const ColoredBox(
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
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${priceFmt.format(menu.price)}원',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
