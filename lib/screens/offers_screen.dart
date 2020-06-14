import 'package:flutter/material.dart';
import 'package:pin_point/style/hexa_color.dart';

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
    Color color2 = HexColor("#f05a2b");
  Color color1 = HexColor("#223469");



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers'),
        backgroundColor: color1,
      ),
      body: Center(
    
      ),
    );
  }
}