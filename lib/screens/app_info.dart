import 'package:flutter/material.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  Color color1 = HexColor("#333132"); //deep gray
  Color color2 = HexColor("#F15A29");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('App Info'),
          backgroundColor: color1,
        ),
        body: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'PinPoint',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: color2),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 18, color: color2),
                  ),
                  
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Container(
                           child: Image.asset(
              'images/icon5.png',
             
              fit: BoxFit.fill,
            ),
                         ),
                       ),
                ],
              ),
            ),
          ),
        ));
  }
}
