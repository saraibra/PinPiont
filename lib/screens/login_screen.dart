import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/models/user.dart';
import 'package:pin_point/screens/bottom_navigation.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/password_reset.dart';
import 'package:pin_point/screens/register.dart';
import 'package:pin_point/screens/settings_screen.dart';
import 'package:pin_point/screens/sign_controller.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:flutter/services.dart';
import 'package:pin_point/utilities/custom_raised_button.dart';
import 'package:pin_point/utilities/helper.dart';

import 'package:pin_point/utilities/rounded_button.dart';
import 'package:pin_point/utilities/size_config.dart';
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
  // for internet
  bool dialogIsVisible = false;
  BuildContext ctx;
  bool canProceed = true;

  bool isOffline = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ///////
  bool showSpinner = false;
  FirebaseUser mCurrentUser;

  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  Color color3 = HexColor("#c0c0c0");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//Firebase Auth and .instance is use to directly contact to firebase

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // using for grab the form key for our form data

  //there are only 2 input in sigin page so declare here

// checkAuthentication method is continuasly check wether the user is loged in or not
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        pushNewScreen(
          context,
          screen: HomeScreen(),
          platformSpecific:
              false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
          withNavBar: true, // OPTIONAL VALUE. True by default.
        );
      }
    });
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
          dialogIsVisible = false;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          isOffline = false;
          dialogIsVisible = false;
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

  navigateToHomePage() {
    pushNewScreen(
      context,
      screen: BottomNavigation(),
      platformSpecific:
          false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
      withNavBar: true, // OPTIONAL VALUE. True by default.
    );
  }

  navigateToSignupScreen() {
    pushNewScreen(
      context,
      screen: SignInController(
        isOfline: isOffline,
      ),
      platformSpecific:
          false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
      withNavBar: false, // OPTIONAL VALUE. True by default.
    );
  }

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

    DocumentSnapshot ds =
        await Firestore.instance.collection('users').document(user.uid).get();
    if (ds.exists) {
      //  hideProgress();
      pushNewScreen(
        context,
        screen: BottomNavigation(),
        platformSpecific:
            false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
        withNavBar: true, // OPTIONAL VALUE. True by default.
      );
    } else {
      User userData = User(
          firstName: user.displayName,
          lastName: " ",
          email: user.email,
          profileImage: user.photoUrl,
          phone: " ",
          active: true,
          uid: user.uid,
          points: 0,
          waitingList: false);
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .setData(userData.toJson())
          .then((onValue) {
        //hideProgress();
        pushNewScreen(
          context,
          screen: BottomNavigation(),
          platformSpecific:
              false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
          withNavBar: true, // OPTIONAL VALUE. True by default.
        );
      });
    }

    return 'signInWithGoogle succeeded: $user';
  }

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
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth * 0.9;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Container(
                            width: SizeConfig.blockSizeHorizontal * 10,
                            height: SizeConfig.blockSizeVertical * 10,
                            child: Image.asset('images/icon5.png'),
                          ),
                        ),
                         Container(
                          alignment: Alignment.center,
                            height: SizeConfig.screenHeight / 4,
                            child: Column(
                              
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  child: Text(
                                    "HELLO,",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: color2,
                                    ),
                                  ),
                                ),
                                Text(
                                  "WELCOME TO PINPOINT.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: color2,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '''Sign in to get live data of your favourite place, plan your
daily trips, earn reward points, and so much more...''',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: color2,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                             Container(
                          height: SizeConfig.screenHeight / 2,
                          width: deviceWidth-32,
                          child: Column(
                            children: <Widget>[
                              Hero(
                                tag: 'google',
                                child: SocialSignInButton(
                                    assetName: 'images/google_logo.png',
                                    text: 'SIGN IN WITH GOOGLE',
                                    textColor: color1,
                                    color: Colors.white,
                                    onPressed: () {
                                      if (!isOffline) {
                                        signInWithGoogle();
                                      } else {
                                        _displaySnackBar(context);
                                      }
                                    }),
                              ),
                              SizedBox(height: 16.0),
                               Hero(
                                tag: 'facebook',
                                child: SocialSignInButton(
                                  assetName: 'images/facebook_logo.png',
                                  text: 'SIGN IN WITH FACEBOOK',
                                  textColor: Colors.white,
                                  color: Color(0xFF334D92),
                                  onPressed: () async {
                                    if (!isOffline) {
                                      signInUsingFacebook();
                                    } else {
                                      _displaySnackBar(context);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 1,
                                    width: 50,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "OR",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    width: 50,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.0),
                              CustomRaisedButton(
                                color: color2,
                                child: Text(
                                  'CREATE ACCOUNT',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  navigateToSignupScreen();
                                },
                              ),
                            ],
                          ),)
                      ]),
                ),
              ),
            ),
          ),

          /* Container(
  alignment: Alignment.center,
                 width:deviceWidth,
                 

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Container(
                            
                            width: SizeConfig.blockSizeHorizontal * 10,
                            height: SizeConfig.blockSizeVertical * 10,
                            child: Image.asset('images/icon5.png'),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                            height: SizeConfig.screenHeight / 4,
                            child: Column(
                              
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 32.0),
                                  child: Text(
                                    "HELLO,",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: color2,
                                    ),
                                  ),
                                ),
                                Text(
                                  "WELCOME TO PINPOINT.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: color2,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '''Sign in to get live data of your favourite place, plan your
daily trips, earn reward points, and so much more...''',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: color2,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          height: SizeConfig.screenHeight / 2,
                          width: deviceWidth-32,
                          child: Column(
                            children: <Widget>[
                              Hero(
                                tag: 'google',
                                child: SocialSignInButton(
                                    assetName: 'images/google_logo.png',
                                    text: 'SIGN IN WITH GOOGLE',
                                    textColor: color1,
                                    color: Colors.white,
                                    onPressed: () {
                                      if (!isOffline) {
                                        signInWithGoogle();
                                      } else {
                                        _displaySnackBar(context);
                                      }
                                    }),
                              ),
                              SizedBox(height: 16.0),
                              Hero(
                                tag: 'facebook',
                                child: SocialSignInButton(
                                  assetName: 'images/facebook_logo.png',
                                  text: 'SIGN IN WITH FACEBOOK',
                                  textColor: Colors.white,
                                  color: Color(0xFF334D92),
                                  onPressed: () async {
                                    if (!isOffline) {
                                      signInUsingFacebook();
                                    } else {
                                      _displaySnackBar(context);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 1,
                                    width: 50,
                                    color: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "OR",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    width: 50,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.0),
                              CustomRaisedButton(
                                color: color2,
                                child: Text(
                                  'CREATE ACCOUNT',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  navigateToSignupScreen();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),*/
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
        DocumentSnapshot ds = await Firestore.instance
            .collection('users')
            .document(userUid)
            .get();
        if (ds.exists) {
          // hideProgress();
          pushNewScreen(
            context,
            screen: BottomNavigation(),
            platformSpecific:
                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
            withNavBar: true, // OPTIONAL VALUE. True by default.
          );
        } else {
          User user = User(
              firstName: profile['first_name'],
              lastName: profile['last_name'],
              email: profile['email'],
              profileImage: profile["picture"]["data"]["url"],
              phone: " ",
              active: true,
              uid: userUid,
              points: 0,
              waitingList: false);
          await Firestore.instance
              .collection('users')
              .document(userUid)
              .setData(user.toJson())
              .then((onValue) {
            // hideProgress();
            pushNewScreen(
              context,
              screen: BottomNavigation(),
              platformSpecific:
                  false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
              withNavBar: true, // OPTIONAL VALUE. True by default.
            );
          });
        }
      });
    }
  }
}
