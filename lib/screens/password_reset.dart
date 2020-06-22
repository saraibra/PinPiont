import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/rounded_button.dart';

class PasswordResset extends StatefulWidget {
  @override
  _PasswordRessetState createState() => _PasswordRessetState();
}

class _PasswordRessetState extends State<PasswordResset> {
  String _email;
 Color color1 = HexColor("#1e1e1e");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showSpinner = false;
  showError(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  navigateToSigninScreen() {
    Navigator.pushNamed(context, '/signIn');
  }

  void _changePassword() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      _formKey.currentState.save();
      try {
        //Create an instance of the current user.
        await _auth.sendPasswordResetEmail(email: _email);
        //Pass in the password to updatePassword.

        Fluttertoast.showToast(
            msg: "Reset password email is successfully sent",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 3,
            backgroundColor: color2,
            textColor: Colors.white,
            fontSize: 16.0);
        navigateToSigninScreen();
      } catch (e) {
        setState(() {
          showSpinner = false;
        });
        showError(e.message);
      }
    }
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: KTextFieldDecoration.copyWith(
        hintText: 'Enter your email',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (input) => _email = input,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Reset Password',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: color1,
        ),
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 32,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildEmailTextField(),
                          SizedBox(
                            height: 16,
                          ),
                          Hero(
                              tag: 'submit',
                              child: RoundedButton(
                                color: color1,
                                text: 'Submit ',
                                onPress: () {
                                  _changePassword();
                                },
                              )),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
