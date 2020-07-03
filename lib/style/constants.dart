import 'package:flutter/material.dart';

import 'hexa_color.dart';

  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange





const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(
      
      color:Color(0xff333132), width: 2.0),
  ),
);
const KTextFieldDecoration = InputDecoration(
  hintText: 'Enter your value',
  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xff333132), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Color(0xffF15A29), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
);const KTextFieldDecoration2 = InputDecoration(
  hintText: 'Enter your value',
hintStyle: TextStyle(
  color: Color(0xffc0c0c0)
),
  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Color(0xffc0c0c0), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Colors.white, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(3.0)),
  ),
);