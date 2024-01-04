import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';



import '../utils/Utils.dart';
import '../utils/app_values.dart';
import '../utils/color_code.dart';
import '../utils/screenUtils.dart';
import '../utils/text_view.dart';
import 'asset_image.dart';

Widget eventRowDataDetails({textt, imageUrl, textColor, imageColor, fontSize}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AssetImageWidget(
        imageUrl,
        color: imageColor,
        imageWidth: width_15,
      ).paddingOnly(right: margin_5, top: margin_3),
      Flexible(
        child: Text(
          textt ?? 'N/A',
          maxLines: 2,
          style: TextStyle(
              fontFamily: 'Poppins Medium',
              fontWeight: FontWeight.w500,
              color: textColor ??
                  Color(Utils.hexStringToHexInt(ColorsCode.backgroundColor)),
              fontSize: fontSize),
        ),
      ),
    ],
  );
}

Widget providerDetails({heading, subHeading, context}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextView(heading,
              textStyle: TextStyle(
                  fontFamily: 'Poppins Bold',
                  color: lightCreamColor,
                  fontSize: ScreenUtils.isSmallScreen(context)
                      ? Get.width * 0.11 - 3
                      : Get.width * 0.06 - 2,
                  fontWeight: FontWeight.bold))
          .paddingOnly(bottom: margin_2),
      TextView(subHeading,
              textStyle: TextStyle(
                  fontFamily: 'Poppins Medium',
                  color: lightCreamColor,
                  fontSize: ScreenUtils.isSmallScreen(context)
                      ? Get.width * 0.04
                      : Get.width * 0.02,
                  fontWeight: FontWeight.w500))
          .paddingOnly(bottom: margin_2),
    ],
  );
}



