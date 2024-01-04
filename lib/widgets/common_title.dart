import 'package:flutter/material.dart';

import '../utils/ScreenUtils.dart';

class CommonTitlt extends StatefulWidget {
  String _title;

  CommonTitlt(String title, {Key? key})
      : _title = title,
        super(key: key);

  @override
  State<CommonTitlt> createState() => _CommonTitltState();
}

class _CommonTitltState extends State<CommonTitlt> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Text(
      widget._title,
      style: TextStyle(
          fontFamily: 'Poppins Bold',
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: ScreenUtils.isSmallScreen(context)
              ? width * 0.06
              : width * 0.04 - 5),
    );
  }
}
