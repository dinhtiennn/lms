import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../configs/configs.dart';

class WidgetButton extends StatelessWidget {
  const WidgetButton(
      {Key? key,
      required this.text,
      this.color,
      this.borderColor,
      this.styles,
      required this.onTap,
      this.colorText,
      this.padding,
      this.iconHeader,
      this.radius,
      this.radiusAll})
      : super(key: key);

  final String text;
  final Color? color;
  final Color? borderColor;
  final Color? colorText;
  final TextStyle? styles;
  final VoidCallback onTap;
  final double? padding;
  final Widget? iconHeader;
  final double? radiusAll;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding ?? 16),
        decoration: BoxDecoration(
            color: color ?? primary,
            border: Border.all(color: borderColor ?? primary),
            borderRadius: radius ?? BorderRadius.circular(radiusAll ?? 99)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconHeader ?? const SizedBox(),
              iconHeader != null ? SizedBox(width: 8) : const SizedBox(),
              Text(text.tr, style: styles ?? styleSmallBold.copyWith(color: colorText ?? white)),
            ],
          ),
        ),
      ),
    );
  }
}
