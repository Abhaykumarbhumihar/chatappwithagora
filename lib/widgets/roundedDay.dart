import 'package:flutter/material.dart';

import '../utils/Utils.dart';
import '../utils/color_code.dart';

class RoundedTextList extends StatefulWidget {
  @override
  State<RoundedTextList> createState() => _RoundedTextListState();
}

class _RoundedTextListState extends State<RoundedTextList> {
  final List<String> itemList = ['Day 1', 'Day 2', 'Day 3'];
  int selectedItemIndex = -1;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(width * 0.1),
          onTap: () {
            setState(() {
              selectedItemIndex = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              height: height * 0.03,
              width: width * 0.2 + 8,
              decoration: BoxDecoration(
                color: selectedItemIndex == index
                    ? Colors.white
                    : Color(Utils.hexStringToHexInt(ColorsCode.listdayColor)),
                borderRadius: BorderRadius.circular(width * 0.1),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    itemList[index],
                    style: TextStyle(
                      fontFamily: 'Poppins Medium',
                      color: selectedItemIndex == index
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
