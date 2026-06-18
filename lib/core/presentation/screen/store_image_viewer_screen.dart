import 'package:capstone_2026/core/presentation/component/network/app_cached_network_image.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

/// 매장 사진 전체 화면 뷰어 (핀치 줌 + 좌우 스와이프).
class StoreImageViewerScreen extends StatefulWidget {
  const StoreImageViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<String> imageUrls,
    required int initialIndex,
  }) {
    final urls = imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    if (urls.isEmpty) {
      return Future.value();
    }

    final safeIndex = initialIndex.clamp(0, urls.length - 1);

    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => StoreImageViewerScreen(
          imageUrls: urls,
          initialIndex: safeIndex,
        ),
      ),
    );
  }

  @override
  State<StoreImageViewerScreen> createState() => _StoreImageViewerScreenState();
}

class _StoreImageViewerScreenState extends State<StoreImageViewerScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: urls.length > 1
            ? Text(
                '${_currentIndex + 1} / ${urls.length}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: urls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return _ZoomableStoreImage(url: urls[index]);
        },
      ),
    );
  }
}

class _ZoomableStoreImage extends StatelessWidget {
  const _ZoomableStoreImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: AppCachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          width: double.infinity,
          placeholder: (_, _) => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          errorWidget: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondary,
            size: 64,
          ),
        ),
      ),
    );
  }
}
