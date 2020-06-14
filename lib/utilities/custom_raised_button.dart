import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  final Widget child;
  final Color color;

  final VoidCallback onPressed;
  CustomRaisedButton(
      {@required this.child, @required this.color, @required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          minWidth: double.infinity,
          child: child,
          onPressed: onPressed,
          height: 42,
          color: color,
          disabledColor: color,
        ),
      ),
    );
  }
}
