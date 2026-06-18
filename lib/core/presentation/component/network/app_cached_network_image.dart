import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 300),
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return AppNetworkImage(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: placeholder == null
            ? null
            : (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return placeholder!(context, imageUrl);
              },
        errorBuilder: errorWidget == null
            ? null
            : (context, error, stackTrace) =>
                errorWidget!(context, imageUrl, error),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
