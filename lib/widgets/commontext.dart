import 'package:flutter/material.dart';

class CommonText extends StatefulWidget {
  String _text;

  CommonText(String text, {Key? key})
      : _text = text,
        super(key: key);

  @override
  State<CommonText> createState() => _CommonTextState();
}

class _CommonTextState extends State<CommonText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 6.0),
      child: Text(
        widget._text,
        style: const TextStyle(
          fontFamily: 'Poppins Medium',
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
