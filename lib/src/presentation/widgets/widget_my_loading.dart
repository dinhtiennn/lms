import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../configs/configs.dart';

class MyLoading extends StatelessWidget {
  final bool opacity;
  final Color? color;
  final double? size;

  const MyLoading({Key? key, this.opacity = true, this.color, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: transparent,
        child: opacity
            ? Center(
                child: LoadingAnimationWidget.stretchedDots(
                  color: primary,
                  size: 50,
                ),
              )
            : SizedBox(height: 50, width: 50));
  }
}
