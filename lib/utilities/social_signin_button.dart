import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_point/utilities/custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton(
      { @required String text,
        @required Color color,
        @required Color textColor,
        @required String assetName,
        @required VoidCallback onPressed})
      : super(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(assetName),
                  Text(
                    text,
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  Opacity(
                      opacity: 0.0, child: Image.asset(assetName),
                  )
                ],
              ),
            ),
            color: color,
         
            onPressed: onPressed);
}
