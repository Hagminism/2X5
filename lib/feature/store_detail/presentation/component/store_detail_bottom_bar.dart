import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreDetailBottomBar extends StatelessWidget {
  final void Function() onBookmarkTap;
  final void Function() onCallTap;
  final void Function() onReserveTap;

  const StoreDetailBottomBar({
    required this.onBookmarkTap,
    required this.onCallTap,
    required this.onReserveTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBookmarkTap,
              icon: const Icon(Icons.bookmark_border_rounded),
            ),
            IconButton(
              onPressed: onCallTap,
              icon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onReserveTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFFF4D00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '예약하기',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
