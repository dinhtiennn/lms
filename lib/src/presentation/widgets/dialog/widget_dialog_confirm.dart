import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import '../../../configs/constanst/constants.dart';
import '../widget_button.dart';

class WidgetDialogConfirm extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTapConfirm;
  final VoidCallback? onTapCancel;
  final bool reversalButton;
  final TextStyle? titleStyle;
  final Color? colorButtonAccept;
  final bool? acceptOnly;

  const WidgetDialogConfirm(
      {Key? key,
      required this.title,
      required this.content,
      required this.onTapConfirm,
      this.reversalButton = false,
      this.onTapCancel,
      this.titleStyle,
      this.colorButtonAccept,
      this.acceptOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Get.width - 30,
        padding: EdgeInsets.all(16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10)),
        child: Material(
          color: transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 24),
                  Text(title, style: titleStyle ?? styleLargeBold.copyWith(color: error)),
                  acceptOnly == true ? SizedBox() : InkWell(onTap: () => Get.back(), child: Icon(Icons.clear, size: 24, color: grey4))
                ],
              ),
              SizedBox(height: 8),
              Text(content, style: styleSmall.copyWith(color: grey4, fontSize: 13), textAlign: TextAlign.center),
              SizedBox(height: 24),
              reversalButton
                  ? Row(
                      children: [
                        Expanded(
                          child: WidgetButton(
                            padding: 11,
                            text: 'yes'.tr,
                            onTap: onTapConfirm,
                            color: colorButtonAccept ?? white,
                            borderColor: colorButtonAccept ?? white,
                            colorText: primary,
                          ),
                        ),
                        SizedBox(width: 10),
                        acceptOnly == true
                            ? SizedBox()
                            : Expanded(
                                child: WidgetButton(
                                  padding: 11,
                                  text: 'cancel'.tr,
                                  onTap: onTapCancel ?? () => Get.back(),
                                ),
                              ),
                      ],
                    )
                  : Row(
                      children: [
                        acceptOnly == true
                            ? SizedBox()
                            : Expanded(
                                child: WidgetButton(
                                  padding: 11,
                                  text: 'cancel'.tr,
                                  onTap: onTapCancel ?? () => Get.back(),
                                  color: white,
                                  borderColor: white,
                                  colorText: primary,
                                ),
                              ),
                        SizedBox(width: 10),
                        Expanded(
                          child: WidgetButton(
                            padding: 11,
                            text: 'yes'.tr,
                            onTap: onTapConfirm,
                            color: colorButtonAccept ?? white,
                            borderColor: colorButtonAccept ?? white,
                            colorText: white,
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
