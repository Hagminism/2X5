import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.imageUrl, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.errorBuilder,
    this.loadingBuilder,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}
