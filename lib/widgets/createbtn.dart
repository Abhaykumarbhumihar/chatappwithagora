import 'package:flutter/material.dart';
import 'package:get/get.dart';



import '../utils/app_values.dart';
import '../utils/color_code.dart';
import '../utils/screenUtils.dart';

class MaterialButtonWidget extends StatelessWidget {
  final String? buttonText;
  final buttonTextStyle;
  final Color? buttonnColor;
  final Color? textColor;
  final double? buttonRadius;
  final double? minWidth;
  final double? minHeight;
  final double? verticalPadding;
  final double? horizontalPadding;
  final onPressed;
  final elevation;
  final borderColor;
  final borderWidth;
  final widget;

  const MaterialButtonWidget({
    Key? key,
    this.buttonText = "",
    this.buttonnColor,
    this.buttonTextStyle,
    this.textColor,
    this.buttonRadius,
    this.onPressed,
    this.elevation,
    this.borderColor,
    this.borderWidth,
    this.minWidth,
    this.minHeight,
    this.verticalPadding,
    this.horizontalPadding,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return MaterialButton(
        height: minHeight,
        splashColor: Colors.transparent,
        minWidth: minWidth ?? Get.width,
        color: buttonnColor ?? buttonColor,
        elevation: elevation ?? 0.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius ?? radius_28)),
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? margin_10,
            horizontal: horizontalPadding ?? margin_25),
        child: widget ??
            Text(buttonText!,
                style: buttonTextStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize:
                          (width < 800 ? width * 0.045 : width * 0.03 - 5),
                      fontFamily: "Poppins Medium",
                    )));
  }
}
