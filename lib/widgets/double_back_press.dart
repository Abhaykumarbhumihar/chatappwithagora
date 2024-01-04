import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


import '../utils/app_values.dart';
import '../utils/color_code.dart';

class DoubleBack extends StatefulWidget {
  final Widget child;
  final String message;
  final int waitForSecondBackPress;
  final Function? onFirstBackPress;
  final bool condition;
  final VoidCallback? onConditionFail;
  final TextStyle textStyle;
  final Color background;
  final double backgroundRadius;

  /// DoubleBack, wrap a widget to use it
  const DoubleBack({
    Key? key,
    required this.child,
    this.message = 'Press one more time to push app into background',
    this.waitForSecondBackPress = 2,
    this.onFirstBackPress,
    this.condition = true,
    this.onConditionFail,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.white),
    this.background = const Color(0xAA000000),
    this.backgroundRadius = 20,
  }) : super(key: key);

  @override
  _DoubleBackState createState() => _DoubleBackState();
}

class _DoubleBackState extends State<DoubleBack> {
  bool tapped = false;

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) {
      return WillPopScope(
        onWillPop: () async {
          if (widget.condition) {
            if (tapped) {
              return true;
            } else {
              tapped = true;
              Timer(
                Duration(
                  seconds: widget.waitForSecondBackPress,
                ),
                resetBackTimeout,
              );

              if (widget.onFirstBackPress != null) {
                widget.onFirstBackPress!(context);
              } else {
                _showToast(context);
                // Get.snackbar('ICEF',
                //     'Press one more time to push app into background',
                //     barBlur: radius_50,
                //     backgroundColor: Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
                //     snackPosition: SnackPosition.BOTTOM,
                //     colorText: Colors.white,
                //     duration: const Duration(milliseconds: 1500),
                //     margin: EdgeInsets.symmetric(horizontal: margin_10, vertical: margin_20));
              }

              return false;
            }
          } else {
            if (widget.onConditionFail != null) {
              widget.onConditionFail!();
            }
            return false;
          }
        },
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }

  void resetBackTimeout() {
    tapped = false;
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Press one more time to push app into background'),
      ),
    );
  }
}
