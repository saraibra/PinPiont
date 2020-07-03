import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final Widget child;
  final Color color;
   
  final VoidCallback onPressed;
  CustomRaisedButton(
      {@required this.child, @required this.color, @required this.onPressed});
  @override
  Widget build(BuildContext context) {
     final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =deviceWidth-32;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(3.0),
        child: ButtonTheme(
          height: 45,
                  child: MaterialButton(
            minWidth: double.infinity,
            child: child,
            onPressed: onPressed,
           // height: 42,
            color: color,
            disabledColor: color,
          ),
        ),
      ),
    );
  }
}
