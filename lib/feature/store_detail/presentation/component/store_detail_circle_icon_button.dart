import 'package:flutter/material.dart';

class StoreDetailCircleIconButton extends StatelessWidget {
  final IconData icon;
  final void Function() onTap;

  const StoreDetailCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
