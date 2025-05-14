import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DatePickerTheme with DiagnosticableTreeMixin {
  final Widget? header;
  final TextStyle? cancelStyle;
  final TextStyle? doneStyle;
  final TextStyle? itemStyle;
  final Color? backgroundColor;
  final Color? headerColor;

  final double containerHeight;
  final double titleHeight;
  final double itemHeight;
  final double bottomButton;

  const DatePickerTheme({
    this.header,
    this.cancelStyle,
    this.doneStyle,
    this.itemStyle = const TextStyle(color: Color(0xFFA9A9A9), fontSize: 18),
    this.backgroundColor = Colors.white,
    this.headerColor,
    this.containerHeight = 252.0,
    this.titleHeight = 44.0,
    this.itemHeight = 36.0,
    this.bottomButton = 52,
  });
}
