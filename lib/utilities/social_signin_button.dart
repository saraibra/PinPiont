import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_point/utilities/custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton(
      {@required String text,
      @required Color color,
      @required Color textColor,
      @required String assetName,
      @required VoidCallback onPressed})
      : super(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    assetName,
                    height: 16,
                    width: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FittedBox(
                      child: Text(
                        text,
                        textAlign: TextAlign.justify,
                        style: TextStyle(color: textColor,),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: Image.asset(assetName),
                  )
                ],
              ),
            ),
            color: color,
            onPressed: onPressed);
}
