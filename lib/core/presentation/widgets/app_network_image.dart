import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lms_app/core/presentation/widgets/app_loader.dart';

class AppNetworkImage extends StatefulHookWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.radius,
    this.borderRadius = 0,
    this.clickable = false,
    this.onSaveImage,
    this.placeholderBackground,
    this.circular = false,
    this.aspectRatio = 1.48,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double? radius;
  final double aspectRatio;
  final bool clickable;
  final double borderRadius;
  final VoidCallback? onSaveImage;
  final Color? placeholderBackground;
  final bool circular;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        AbsorbPointer(
          absorbing: !widget.clickable,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              imageBuilder: (context, image) {
                return widget.circular
                    ? CircleAvatar(
                        backgroundImage: image,
                        radius: widget.radius,
                      )
                    : Image(image: image, fit: widget.fit);
              },
              progressIndicatorBuilder: (_, __, progress) {
                return AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: widget.circular
                          ? null
                          : BorderRadius.circular(widget.borderRadius),
                      color:
                          widget.placeholderBackground ??
                          theme.colorScheme.onPrimary,
                      shape: widget.circular
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                    ),
                    alignment: Alignment.center,
                    width: widget.width,
                    height: widget.height,
                    child: AppLoader(
                      value: progress.progress,
                      size: widget.circular
                          ? Size.fromRadius((widget.radius ?? 24) * 0.25)
                          : null,
                    ),
                  ),
                );
              },
              errorWidget: (_, error, ___) {
                return SizedBox.shrink();

                //  ClipOval(
                //   clipBehavior: widget.circular ? Clip.hardEdge : Clip.none,
                //   child: AspectRatio(
                //     aspectRatio: widget.aspectRatio,
                //     child: Image.asset(ImageManager().defaultPlaceholder),
                //   ),
                // );
              },
              filterQuality: FilterQuality.none,
              width: widget.radius ?? widget.width,
              height: widget.radius ?? widget.height,
              memCacheWidth: int.tryParse(widget.width.toString()),
              memCacheHeight: int.tryParse(widget.height.toString()),
              fit: widget.fit,
            ),
          ),
        ),
        if (widget.onSaveImage != null)
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              onPressed: widget.onSaveImage,
              icon: Icon(
                Icons.save_alt_rounded,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
