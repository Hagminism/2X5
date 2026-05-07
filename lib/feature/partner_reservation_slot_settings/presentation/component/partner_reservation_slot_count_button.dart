import 'package:flutter/material.dart';

class PartnerReservationSlotCountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PartnerReservationSlotCountButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
