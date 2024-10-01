import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/image/memory_image.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart' show Token;
import 'widget_constant.dart';

class CircleAssetsImgaeView extends StatelessWidget {
  const CircleAssetsImgaeView(this.assetPath,
      {this.radius = 120,
      this.backgroundColor = Colors.transparent,
      super.key});
  final APPImage assetPath;
  final double radius;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: CacheMemoryImageProvider(assetPath),
      radius: radius,
      backgroundColor: backgroundColor,
      onBackgroundImageError: (e, d) {},
    );
  }
}

class CircleAPPImageView extends StatelessWidget {
  const CircleAPPImageView(this.image,
      {this.onProgress,
      this.onError,
      this.radius = 120,
      super.key,
      this.onNull = "U",
      this.imageColor});
  final APPImage? image;
  final double radius;
  final String onNull;
  final FuncWidgetContext? onProgress;
  final FuncWidgetContext? onError;
  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return _CircleAPPImageView(radius: radius, onNull: onNull, child: null);
    }
    return Image(
        color: imageColor,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress != null && onProgress != null) {
            return onProgress!.call(context);
          }
          return _CircleAPPImageView(
              radius: radius, onNull: onNull, child: child);
        },
        image: CacheMemoryImageProvider(image!),
        errorBuilder: (context, error, stackTrace) => _CircleAPPImageView(
            radius: radius, onNull: onNull, child: onError?.call(context)));
  }
}

class _CircleAPPImageView extends StatelessWidget {
  const _CircleAPPImageView(
      {this.child, required this.radius, required this.onNull});
  final double radius;
  final String onNull;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: child != null
          ? context.colors.transparent
          : context.colors.primaryContainer,
      radius: radius,
      child: child ??
          Text(
            onNull,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: radius,
                color: context.colors.onPrimaryContainer),
          ),
    );
  }
}

class CircleTokenImageView extends StatelessWidget {
  const CircleTokenImageView(this.token, {this.radius = 120, super.key});
  final Token token;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        (token.name.isEmpty ? "" : token.name[0]).toUpperCase();
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow:
              token.assetLogo != null ? [] : [WidgetConstant.circleShadow]),
      child: CircleAvatar(
        backgroundImage: token.assetLogo != null
            ? CacheMemoryImageProvider(token.assetLogo!)
            : null,
        radius: radius,
        backgroundColor: token.assetLogo != null
            ? context.colors.surface
            : context.colors.primaryContainer,
        child: token.assetLogo != null
            ? null
            : Text(
                symbol,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: radius,
                    color: context.colors.onPrimaryContainer),
              ),
      ),
    );
  }
}

class APPImageProvider extends StatelessWidget {
  final APPImage image;
  final String? onNull;
  const APPImageProvider(this.image, {this.onNull, super.key});
  @override
  Widget build(BuildContext context) {
    return Image(
      image: CacheMemoryImageProvider(image),
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image),
    );
  }
}
