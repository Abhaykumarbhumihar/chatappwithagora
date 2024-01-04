import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

import '../utils/app_values.dart';
import '../utils/color_code.dart';
import '../utils/screenUtils.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var height = double.infinity;
    var width = double.infinity;
    return Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius_15),
          color: welcomeColor,
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(0, 5))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/svg/ICEF_WHITE.svg',
            color: Colors.white,
            height: height_30,
          ).paddingOnly(bottom: margin_10),
          Text(
            'Welcome Sarah',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins Bold',
                fontSize: ScreenUtils.isSmallScreen(context)
                    ? Get.width * 0.09
                    : Get.width * 0.06,
                fontWeight: FontWeight.w800),
          )
        ],
      ).paddingOnly(
          left: margin_15, right: margin_15, top: margin_25, bottom: margin_15),
    );
  }
}
