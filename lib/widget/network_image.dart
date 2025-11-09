import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String url;
  final Map<String, String>? headers;
  final double maxWidth;
  final double maxHeight;
  final bool large;
  final Widget? errorWidget;

  const NetworkImageWidget({
    super.key,
    required this.url,
    this.headers,
    required this.maxWidth,
    required this.maxHeight,
    this.large = false,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(large ? 8 : 4),
      child: CachedNetworkImage(
        imageUrl: url,
        httpHeaders: headers,
        width: maxWidth,
        height: maxHeight,
        memCacheWidth: maxWidth.cacheSize(context),
        errorWidget: (context, url, error) {
          if (errorWidget != null) {
            return errorWidget!;
          }
          return Container();
        },
        placeholder: (context, url) {
          if (errorWidget != null) {
            return errorWidget!;
          }
          return Container();
        },
        filterQuality: FilterQuality.high,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 0),
        fadeOutDuration: const Duration(milliseconds: 0),
      ),
    );
  }
}

extension ImageExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.of(context).devicePixelRatio).round();
  }
}
