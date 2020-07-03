import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/models/user.dart';
import 'package:pin_point/screens/email_login.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/settings_screen.dart';
//import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/rounded_button.dart';
import 'package:pin_point/utilities/size_config.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bottom_navigation.dart';

class RegisterScreen extends StatefulWidget {
  static String id = 'RegisterScreen';
  final bool isOfline;

  const RegisterScreen({Key key, this.isOfline}) : super(key: key);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isOffline = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ///////

  bool showSpinner = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  String _value;
  String dateOfBirth;
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "home");
      }
    });
  }

  navigateToEmailLoginScreen() {
    pushNewScreen(
      context,
      screen: EmailLogin(),
      platformSpecific:
          false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
      withNavBar: false, // OPTIONAL VALUE. True by default.
    );
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
    super.initState();
  }

// signup for formdata to firebase
  void adduser(FirebaseUser signedInUser) async {
    User user = User(
        email: email,
        firstName: firstName,
        phone: phone,
        uid: signedInUser.uid,
        active: true,
        lastName: lastName,
        settings: Settings(allowPushNotifications: true),
        profileImage: '');
    await Firestore.instance
        .collection('users')
        .document(signedInUser.uid)
        .setData(user.toJson());

    Firestore.instance.collection('users').document(signedInUser.uid).setData({
      'uid': signedInUser.uid,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'location': '',
    }).whenComplete(() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  signup() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        showSpinner = true;
      });
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      setState(() {
        showSpinner = false;
      });
      Firestore.instance.collection('users').document(user.uid).setData({
        'uid': user.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        // 'dateOfBirth': dateOfBirth,
        'phone': phone,
        'password': password,
        'profileImage': '',
        'points': 0,
        'waitingList': false
      }).whenComplete(() {
        pushNewScreen(
          context,
          screen: BottomNavigation(),
          platformSpecific:
              false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
          withNavBar: true, // OPTIONAL VALUE. True by default.
        );
      });
    }
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
                child: Text("ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Color color3 = HexColor("#c0c0c0");

  Widget _buildFirstNameFormText() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      keyboardType: TextInputType.text,
      decoration: KTextFieldDecoration2.copyWith(hintText: 'First name'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your first name!';
        }
      },
      onSaved: (input) => firstName = input,
    );
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1980),
        lastDate: new DateTime(2100));
    if (picked != null) setState(() => _value = picked.toString());
  }

  Widget _buildBirthdayField() {
    return InkWell(
      onTap: () {
        _selectDate(); // Call Function that has showDatePicker()
      },
      child: IgnorePointer(
        child: new TextFormField(
          style: TextStyle(fontSize: 12),
          keyboardType: TextInputType.text,
          decoration: KTextFieldDecoration.copyWith(hintText: 'Date of birth'),
          // validator: validateDob,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please enter your date of birth!';
            }
          },
          onSaved: (_value) => dateOfBirth = _value,
        ),
      ),
    );
  }

  Widget _buildLastNameFormText() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      keyboardType: TextInputType.text,
      decoration: KTextFieldDecoration2.copyWith(hintText: 'Last name'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your last name!';
        }
      },
      onSaved: (input) => lastName = input,
    );
  }

  Widget _buildPhoneFormText() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      keyboardType: TextInputType.phone,
      decoration: KTextFieldDecoration2.copyWith(hintText: 'Phone number'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your phone number!';
        }
      },
      onSaved: (input) => phone = input,
    );
  }

  Widget _buildEmailFormText() {
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
      onSaved: (input) => email = input,
    );
  }

  Widget _buildPasswordFormText() {
    return TextFormField(
      style: TextStyle(fontSize: 12, color: color3),
      obscureText: true,
      decoration:
          KTextFieldDecoration2.copyWith(hintText: 'Enter your Password'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your password!';
        }
      },
      onSaved: (input) => password = input,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    Color color1 = HexColor("#1e1e1e"); //deep gray
    Color color2 = HexColor("#F15A29"); //orange
    SizeConfig().init(context);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: color1),
        child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            backgroundColor: color1,
            body: Container(width: deviceWidth, child: _body())
            /*  SingleChildScrollView(
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
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              _buildFirstNameFormText(),

                              SizedBox(
                                height: 8,
                              ),
                              //  _buildLastNameFormText(),
                              //  SizedBox(
                              //  height: 8,
                              // ),
                              // _buildBirthdayField(),

                              _buildPhoneFormText(),
                              SizedBox(
                                height: 8,
                              ),
                              _buildEmailFormText(),
                              SizedBox(
                                height: 8,
                              ),
                              _buildPasswordFormText(),
                              //SizedBox(
                              //  height: 64,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Center(
                              child: new RichText(
                                text: new TextSpan(
                                  children: [
                                    new TextSpan(
                                      text:
                                          'By creating an account. I accept the ',
                                      style: new TextStyle(
                                          color: color3, fontSize: 10),
                                    ),
                                    new TextSpan(
                                      text: 'Terms and Conditions.',
                                      style: new TextStyle(
                                          color: color2, fontSize: 10),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () {
                                          launch(
                                              'https://drive.google.com/file/d/1ntNVxOOgnBO4hd_xRCVFUTtHU8zp0-fB/view?usp=sharing');
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            RoundedButton(
                              color: color2,
                              text: 'CREATE ACCOUNT',
                              onPress: () {
                                if (!isOffline) {
                                  signup();
                                } else {
                                  _displaySnackBar(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
       */
            ),
      ),
    );
  }
 
  Widget _body() {
        final double deviceWidth = MediaQuery.of(context).size.width;

    return Form(
        key: _formKey,
        child: Container(
          width: deviceWidth,
          child: SingleChildScrollView(
    
              child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildFirstNameFormText(),

                    SizedBox(
                      height: 8,
                    ),
                    _buildLastNameFormText(),
                    SizedBox(
                      height: 8,
                    ),
                    // _buildBirthdayField(),

                    _buildPhoneFormText(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildEmailFormText(),
                    SizedBox(
                      height: 8,
                    ),
                    _buildPasswordFormText(),

                    SizedBox(
                      height: 64,
                    ),
                    Center(
                      child: new RichText(
                        text: new TextSpan(
                          children: [
                            new TextSpan(
                              text: 'By creating an account. I accept the ',
                              style: new TextStyle(
                                color: color3,
                                fontSize: 10,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            new TextSpan(
                              text: 'Terms and Conditions.',
                              style: new TextStyle(
                                color: color2,
                                fontSize: 10,
                                fontFamily: 'Montserrat',
                              ),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  launch(
                                      'https://drive.google.com/file/d/1ntNVxOOgnBO4hd_xRCVFUTtHU8zp0-fB/view?usp=sharing');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    RoundedButton(
                      color: color2,
                      text: 'CREATE ACCOUNT',
                      onPress: () {
                        if (!isOffline) {
                          signup();
                        } else {
                          _displaySnackBar(context);
                        }
                      },
                    ),
                  ],
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
