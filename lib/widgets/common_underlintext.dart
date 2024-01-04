import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class CommonUnderlineText extends StatefulWidget {
  String _text;

  CommonUnderlineText(String text, {Key? key})
      : _text = text,
        super(key: key);

  @override
  State<CommonUnderlineText> createState() => _CommonTextState();
}

class _CommonTextState extends State<CommonUnderlineText> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(right: 8.0, top: 6.0),
      child: Text(
        widget._text,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontFamily: 'Poppins Regular',
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
