import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/models/user.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/settings_screen.dart';
//import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/rounded_button.dart';

class RegisterScreen extends StatefulWidget {
  static String id = 'RegisterScreen';
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool showSpinner = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "home");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

// signup for formdata to firebase
  void adduser(FirebaseUser signedInUser)async {
            User user = User(
            email: email,
            firstName: firstName,
            phone: phone,
            uid: signedInUser.uid,
            active: true,
            lastName: lastName,
            settings: Settings(allowPushNotifications: true),
            profileImage: '');
        await  Firestore.instance
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
        'phone': phone,
        'password': password,
        'profileImage': '',
         'points': 0,

      }).whenComplete(() {
        pushNewScreen(
        context,
        screen: SettingsScreen(),
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

  Widget _buildFirstNameFormText() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: KTextFieldDecoration.copyWith(hintText: 'First name'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter your first name!';
        }
      },
      onSaved: (input) => firstName = input,
    );
  }

  Widget _buildLastNameFormText() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: KTextFieldDecoration.copyWith(hintText: 'Last name'),
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
      keyboardType: TextInputType.phone,
      decoration:
          KTextFieldDecoration.copyWith(hintText: 'Enter your phone number'),
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
      onSaved: (input) => email = input,
    );
  }

  Widget _buildPasswordFormText() {
    return TextFormField(
      obscureText: true,
      decoration:
          KTextFieldDecoration.copyWith(hintText: 'Enter your Password'),
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
 Color color1 =HexColor("#1e1e1e");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign up'),
          backgroundColor: color1,
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: targetWidth,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, top: 32),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildFirstNameFormText(),
                        SizedBox(
                          height: 8,
                        ),
                        _buildLastNameFormText(),
                        SizedBox(
                          height: 8,
                        ),
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
                          height: 24,
                        ),
                        Hero(
                            tag: 'sign up',
                            child: RoundedButton(
                              color: color1,
                              text: 'Sign Up',
                              onPress: () {
                                signup();
                              },
                            ))
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
