import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/models/user.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/password_reset.dart';
import 'package:pin_point/screens/register.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:flutter/services.dart';
import 'package:pin_point/utilities/helper.dart';

import 'package:pin_point/utilities/rounded_button.dart';
import 'package:pin_point/utilities/social_signin_button.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static String id = 'LoginScreen';

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  FirebaseUser mCurrentUser;

  Color color1 = HexColor("#333132"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//Firebase Auth and .instance is use to directly contact to firebase

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // using for grab the form key for our form data

  //there are only 2 input in sigin page so declare here
  String _email, _password;

// checkAuthentication method is continuasly check wether the user is loged in or not
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "home");
      }
    });
  }

  navigateToSignupScreen() {
      pushNewScreen(
        context,
        screen: RegisterScreen(),
        platformSpecific: false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
        withNavBar: true, // OPTIONAL VALUE. True by default.
    );  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = new FacebookLogin();
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    User userData = User(
        firstName: user.displayName,
        lastName: " ",
        email: user.email,
        profileImage: user.photoUrl,
        phone: " ",
        active: true,
        uid: user.uid);
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData(userData.toJson())
        .then((onValue) {
      hideProgress();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomeScreen(
                searchActive: false,
              )));
    });
    return 'signInWithGoogle succeeded: $user';
  }

  navigateToPasswordResetScreen() {
      pushNewScreen(
        context,
        screen: PasswordResset(),
        platformSpecific: false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
        withNavBar: true, // OPTIONAL VALUE. True by default.
    );  }
  //if user is loged out then signup page will open.

// Show message for any kind of error occured in application
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

  // when the application will lauch then it will go for checkAuthentication
  @override
  void initState() {
    super.initState();

    this.checkAuthentication();
  }

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
        });
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

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration:
          KTextFieldDecoration.copyWith(hintText: 'Enter your Password'),
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
      },
      onSaved: (input) => _password = input,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign In'),
          backgroundColor: color1,
        ),
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(top: 24.0, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                      child: Text("Forget your password?",
                          style: TextStyle(fontSize: 20.0, color: color1),
                          textAlign: TextAlign.right),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Hero(
                        tag: 'login',
                        child: RoundedButton(
                          color: color1,
                          text: 'Sign In',
                          onPress: () {
                            signin();
                          },
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 1,
                            width: deviceWidth / 3,
                            color: color2,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "OR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: color2,
                                fontSize: 28,
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: deviceWidth / 3,
                            color: color2,
                          ),
                        ],
                      ),
                    ),
                    Hero(
                      tag: 'google',
                      child: SocialSignInButton(
                        assetName: 'images/google_logo.png',
                        text: 'Sign in with Google',
                        textColor: color1,
                        color: Colors.white,
                        onPressed: signInWithGoogle,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Hero(
                                          tag: 'facebook',
                                          child: SocialSignInButton(
                        assetName: 'images/facebook_logo.png',
                        text: 'Sign in with Facebook',
                        textColor: Colors.white,
                        color: Color(0xFF334D92),
                        onPressed: () async {
                          signInUsingFacebook();
                          /*String uid =  _auth.currentUser().toString();

    final facebookLogin = FacebookLogin();
                      final result = await facebookLogin.logIn(['email']);
                      switch (result.status) {
                        case FacebookLoginStatus.loggedIn:
                          showProgress(
                              context, 'Logging in, please wait...', false);
                          await FirebaseAuth.instance
                              .signInWithCredential(
                                  FacebookAuthProvider.getCredential(
                                      accessToken: result.accessToken.token))
                              .then((AuthResult authResult) async {
                            User user =await getCurrentUser(uid);
                            if (user == null) {
                              _createUserFromFacebookLogin(
                                  result, authResult.user.uid);
                            } else {
                           //   _syncUserDataWithFacebookData(result, user);
                            }
                          });
                          break;
                        case FacebookLoginStatus.cancelledByUser:
                          break;
                        case FacebookLoginStatus.error:
                          showAlertDialog(context, 'Error',
                              'Couldn\'t login via facebook.');
                          break;
                      }*/
                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        navigateToSignupScreen();
                      },
                      child: Text("New to PinPoint? Sign up now",
                          style: TextStyle(fontSize: 20.0, color: color1),
                          textAlign: TextAlign.center),
                    ),
             ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<User> getCurrentUser(String uid) async {
    Firestore firestore = Firestore.instance;
    DocumentReference currentUserDocRef =
        firestore.collection('users').document(uid);
    DocumentSnapshot userDocument =
        await firestore.collection('users').document(uid).get();
    if (userDocument != null && userDocument.exists) {
      return User.fromJson(userDocument.data);
    } else {
      return null;
    }
  }

  //Login with Facebook
  void signInUsingFacebook() async {
    final FacebookLogin facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${token}');
    print(graphResponse.body);

    if (result.status == FacebookLoginStatus.loggedIn) {
      showProgress(context, 'Logging in, please wait...', false);
      final credential = FacebookAuthProvider.getCredential(accessToken: token);
      _auth
          .signInWithCredential(credential)
          .then((AuthResult authResult) async {
        final profile = json.decode(graphResponse.body);
        mCurrentUser = await _auth.currentUser();

        String userUid = mCurrentUser.uid;

        print(userUid);
        User user = User(
            firstName: profile['first_name'],
            lastName: profile['last_name'],
            email: profile['email'],
            profileImage: profile["picture"]["data"]["url"],
            phone: " ",
            active: true,
            uid: userUid);
        await Firestore.instance
            .collection('users')
            .document(userUid)
            .setData(user.toJson())
            .then((onValue) {
          hideProgress();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(
                    searchActive: false,
                  )));
        });
      });
    }
  }
}
