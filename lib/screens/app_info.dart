import 'package:flutter/material.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/size_config.dart';

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29");
  Color color3 = HexColor("#c0c0c0");

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        backgroundColor: color1,
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'PINPOINT',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color2),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(fontSize: 16, color: color3),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        child: Image.asset('images/icon5.png'),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        ' © 2020 Pinpoint',
                        style: TextStyle(fontSize: 16, color: color3),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ));
  }
}
