import 'package:lms/src/presentation/widgets/widget_shimmer.dart';
import 'package:lms/src/presentation/widgets/widget_shimmer_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

import '../../configs/configs.dart';
import '../../utils/utils.dart';
enum ImageNetworkShape { none, circle }

class WidgetImageNetwork extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final ImageNetworkShape? shape;
  final Widget? widgetError;
  final BorderRadius? radius;
  final double? radiusAll;

  const WidgetImageNetwork(
      {Key? key,
      @required this.url,
      this.fit,
      this.radiusAll,
      this.height,
      this.width,
      this.radius,
      this.widgetError,
      this.shape = ImageNetworkShape.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: radius ?? BorderRadius.all(Radius.circular(radiusAll ?? 0)),
        child: OctoImage(
          image: CachedNetworkImageProvider(
            AppUtils.pathMediaToUrl(url ?? ''),
            headers: {
              'Authorization': 'Bearer ${AppPrefs.accessToken}',
            },
          ),

          height: height,
          width: width,
          progressIndicatorBuilder: (context, progress) => WidgetShimmer(
            child: WidgetShimmerContainer(
                height: height,
                width: width,
                radius: radiusAll,
                borderRadius: radius ?? BorderRadius.all(Radius.circular(radiusAll ?? 0))),
          ),
          errorBuilder: (context, error, stackTrace) => widgetError ?? _buildDefaultError(),
          fit: fit ?? BoxFit.cover,
        ));
  }

  Widget _buildDefaultError() {
    return Container(
      width: 100,
      height: 100,
      color: white,
      child: const Icon(
        Icons.error_outline,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
