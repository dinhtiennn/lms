import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configs/configs.dart';

//ignore: must_be_immutable
class WidgetInput extends StatefulWidget {
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Widget? endIcon;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final GestureTapCallback? endIconOnTap;
  bool obscureText;
  final String? hintText;
  final String? titleText;
  final Iterable<String>? autofill;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onSubmit;
  final double? heightSuffix;
  final double? widthSuffix;
  final double? radius;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? titleStyle;
  final int? maxLines;
  final int? minLines;
  final Color? bgColor;
  final bool showEye;
  final bool autoFocus;
  final int? maxLengthField;
  final Color? borderColor;
  final Widget? prefix;
  final Widget? action;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final Function()? onEditingComplete;
  final Function()? onTapSurffix;
  final BorderRadius? borderRadius;
  final double? widthPrefix;
  final double? heightPrefix;

  WidgetInput({
    Key? key,
    this.onTap,
    this.heightSuffix,
    this.readOnly = false,
    this.widthSuffix,
    this.onSubmit,
    this.hintText,
    this.textInputAction,
    this.titleText,
    this.titleStyle,
    this.contentPadding,
    this.onChanged,
    this.validator,
    this.controller,
    this.endIcon,
    this.textInputType = TextInputType.text,
    this.endIconOnTap,
    this.obscureText = false,
    this.style,
    this.hintStyle,
    this.maxLines,
    this.minLines,
    this.bgColor,
    this.inputFormatters,
    this.showEye = false,
    this.autofill,
    this.autoFocus = false,
    this.maxLengthField,
    this.onEditingComplete,
    this.borderColor,
    this.prefix,
    this.action,
    this.suffix,
    this.onTapSurffix,
    this.radius,
    this.borderRadius,
    this.widthPrefix,
    this.heightPrefix,
  }) : super(key: key);

  @override
  State<WidgetInput> createState() => _WidgetInputState();
}

class _WidgetInputState extends State<WidgetInput> {
  TextStyle get defaultStyle => styleSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.titleText != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      widget.titleText ?? '',
                      style: widget.titleStyle,
                    ),
                    SizedBox(
                      height: 8,
                    )
                  ],
                ),
              )
            : const SizedBox(),
        TextFormField(
          textInputAction: widget.textInputAction,
          minLines: widget.minLines ?? 1,
          maxLines: widget.maxLines ?? 1,
          maxLength: widget.maxLengthField,
          autofillHints: widget.autofill,
          onTap: widget.onTap,
          autocorrect: false,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmit,
          validator: widget.validator,
          readOnly: widget.readOnly,
          controller: widget.controller,
          keyboardType: widget.textInputType,
          obscureText: widget.obscureText,
          obscuringCharacter: '*',
          cursorColor: black,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autoFocus,
          onEditingComplete: widget.onEditingComplete,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.bgColor ?? white,
            isCollapsed: true,
            isDense: true,
            prefixIcon: widget.prefix,
            prefixIconConstraints: BoxConstraints.tightFor(
                width: widget.widthPrefix ?? 25.sc,
                height: widget.heightPrefix ?? 25.sc),
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                    .copyWith(right: widget.showEye ? 60 : 0),
            hintText: widget.hintText ?? "",
            hintStyle:
                (widget.hintStyle ?? defaultStyle.copyWith(color: grey2)),
            counterText: '',
            suffixIcon: widget.showEye
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 40,
                      width: 60,
                      child: Center(
                        child: Image.asset(
                            (widget.obscureText)
                                ? AppImages.png('show')
                                : AppImages.png('hide'),
                            width: 20,
                            height: 20),
                      ),
                    ),
                    onTap: () => setState(
                        () => widget.obscureText = !widget.obscureText))
                : InkWell(
                    splashColor: transparent,
                    onTap: widget.onTapSurffix,
                    child: widget.suffix,
                  ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: _border(),
            focusedBorder: _border(),
            enabledBorder: _border(),
            suffixIconConstraints: BoxConstraints.tightFor(
                width: widget.widthSuffix ?? 50,
                height: widget.heightSuffix ?? 50),
          ),
          style: widget.style ?? defaultStyle,
        ),
      ],
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
        borderSide: BorderSide(color: widget.borderColor ?? grey5),
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.radius ?? 99));
  }
}
