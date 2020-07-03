import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPress;
  RoundedButton({this.text, this.color, this.onPress});

  @override
  Widget build(BuildContext context) {
    return  Material(
        color: color,
        borderRadius: BorderRadius.circular(3.0),
        child: MaterialButton(
          onPressed: onPress,
          minWidth: double.infinity,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      
    );
  }
}
