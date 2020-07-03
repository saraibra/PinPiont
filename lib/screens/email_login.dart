import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/bottom_navigation.dart';
import 'package:pin_point/screens/password_reset.dart';
import 'package:pin_point/screens/settings_screen.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/rounded_button.dart';
import 'package:pin_point/utilities/size_config.dart';

class EmailLogin extends StatefulWidget {
    final bool isOfline;

  const EmailLogin({Key key, this.isOfline}) : super(key: key);

  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
    bool isOffline = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ///////
  bool showSpinner = false;
  FirebaseUser mCurrentUser;

  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
    Color color3 = HexColor("#c0c0c0"); //orange

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

//Firebase Auth and .instance is use to directly contact to firebase

  final FirebaseAuth _auth = FirebaseAuth.instance;
  void signin() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        showSpinner = true;
      });
      _formKey.currentState.save();

      // wrapping the firebase call to signInWithEmailAndPassword
      //and in case of any error catch method will work
      try {
        AuthResult user = (await _auth.signInWithEmailAndPassword(
            email: _email, password: _password));
        setState(() {
          showSpinner = false;
          pushNewScreen(
            context,
            screen: BottomNavigation(),
            platformSpecific:
                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
            withNavBar: true, // OPTIONAL VALUE. True by default.
          );
        });
      } catch (e) {
        setState(() {
          showSpinner = false;
        });
        showError(e.message);
      }
    }
  }

   @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    SizeConfig().init(context);

    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          isOffline = false;
         // dialogIsVisible = false;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          isOffline = false;
         // dialogIsVisible = false;
        });
        break;
      case ConnectivityResult.none:
        setState(() => isOffline = true);
        // buildAlertDialog("Internet connection cannot be establised!");
        break;
      default:
        setState(() => isOffline = true);
        break;
    }
  }

 
  @override
  void initState() {
   initConnectivity();
     _connectivitySubscription =
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  print(isOffline.toString());

    super.initState();
  }


  Widget _buildEmailTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      decoration: KTextFieldDecoration2.copyWith(
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

  Widget _buildPasswordTextField() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      decoration:
          KTextFieldDecoration2.copyWith(hintText: 'Enter your Password'),
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
      },
      onSaved: (input) => _password = input,
    );
  }

  navigateToPasswordResetScreen() {
    pushNewScreen(
      context,
      screen: PasswordResset(),
      platformSpecific:
          false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
      withNavBar: false, // OPTIONAL VALUE. True by default.
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: color1),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: color1,
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Text(
                                        "WELCOME!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: color2,
                                        ),
                                      ),
                                    ),
                                    _buildEmailTextField(),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    _buildPasswordTextField(),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        navigateToPasswordResetScreen();
                                      },
                                      child: Text("Forgot your password?",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white),
                                          textAlign: TextAlign.right),
                                    ),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Hero(
                                      tag: 'signIn',
                                      child: RoundedButton(
                                        color: color2,
                                        text: 'SIGN IN',
                                        onPress: () {
                                           if (!isOffline) {
                                          signin();
                                    } else {
                                      _displaySnackBar(context);
                                    }
                                        },
                                      )), //Your widget here,
                              
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
    _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        'Please check your internet connection.',
        style: TextStyle(color: color3),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
