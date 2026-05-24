import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// iOS/iPadOS 공유 시트용 앵커 (AppBar: 공유 → 북마크 순).
Rect _appBarShareButtonOrigin(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  const buttonSize = 48.0;
  const trailingActions = 2;
  return Rect.fromLTWH(
    mediaQuery.size.width - buttonSize * trailingActions - 16,
    mediaQuery.padding.top,
    buttonSize,
    buttonSize,
  );
}

Future<void> shareStoreText(
  BuildContext context, {
  required String text,
  String? subject,
}) {
  return Share.share(
    text,
    subject: subject,
    sharePositionOrigin: _appBarShareButtonOrigin(context),
  );
}
