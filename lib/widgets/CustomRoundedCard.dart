import 'package:flutter/material.dart';

import '../utils/ScreenUtils.dart';

class CustomRoundedCard extends StatefulWidget {
  @override
  State<CustomRoundedCard> createState() => _CustomRoundedCardState();
}

class _CustomRoundedCardState extends State<CustomRoundedCard> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: ScreenUtils.isSmallScreen(context)
          ? height * 0.3 - 20
          : height * 0.3 - 35,
      child: Card(
        elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Colors.grey[300], // Grey background color
      ),
    );
  }
}
