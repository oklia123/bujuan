import 'package:bujuan_music/widgets/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int pWidth;
  final int pHeight;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.pWidth = 300,
    this.pHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.isEmpty
          ? Container(height: height, width: width, color: Colors.grey.withAlpha(140))
          : CachedNetworkImage(
              imageUrl: '$imageUrl?param=${pWidth}y$pHeight',
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
              errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 200),
            ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: LoadingIndicator(
        size: Size((width ?? 0) / 3, (width ?? 0) / 3),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: LoadingIndicator(
        size: Size((width ?? 0) / 3, (width ?? 0) / 3),
      ),
    );
  }
}
