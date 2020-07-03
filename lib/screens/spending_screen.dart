import 'package:flutter/material.dart';
import 'package:pin_point/style/hexa_color.dart';

class SpendingScreen extends StatefulWidget {
  @override
  _SpendingScreenState createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
            child: Text(
          'MY SPENDING',
        )),
        backgroundColor: color1,
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                '''You don't have any  
  spendings for now!''',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          )),
    );
  }
}
