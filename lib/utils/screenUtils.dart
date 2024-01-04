import 'package:flutter/material.dart';

class ScreenUtils {
  static bool isSmallfont(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor < 1.0;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  static double height(BuildContext context){
    return MediaQuery.of(context).size.height;
  }

  static double width(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
}
