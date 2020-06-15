import 'package:flutter/material.dart';
import 'package:pin_point/style/hexa_color.dart';

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers'),
        backgroundColor: color1,
      ),
      body: Center(
    child: Text('There is no offers yet',
    style: TextStyle(
      color: color2,
      fontSize: 24
    ),
    
    ),
      ),
    );
  }
}