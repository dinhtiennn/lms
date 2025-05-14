import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../configs/configs.dart';

enum CustomToastType {
  neutral,
  information,
  success,
  warning,
  error,
}

class CustomToast extends StatelessWidget {
  final CustomToastType type;
  final String message;

  const CustomToast({Key? key, this.type = CustomToastType.neutral, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: transparent,
        child: Container(
          width: Get.width,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: getColor(),
          ),
          child: Text(
            message.tr,
            textAlign: TextAlign.left,
            style: styleSmall.copyWith(color: white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Color getColor() {
    switch (type) {
      case CustomToastType.neutral:
        return grey3;
      case CustomToastType.information:
        return information;
      case CustomToastType.success:
        return success;
      case CustomToastType.warning:
        return warning;
      case CustomToastType.error:
        return error;
    }
  }
}
