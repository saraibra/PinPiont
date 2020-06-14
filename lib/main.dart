import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pin_point/screens/bottom_navigation.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/login_screen.dart';
import 'package:pin_point/screens/offers_screen.dart';
import 'package:pin_point/screens/password_reset.dart';
import 'package:pin_point/screens/places_list.dart';
import 'package:pin_point/screens/profile_screen.dart';
import 'package:pin_point/screens/register.dart';
import 'package:pin_point/screens/settings_screen.dart';
import 'package:pin_point/screens/waiting_list.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:flutter/services.dart';
 Widget homeScreen;
void main()async{ 
  
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool seen = sharedPreferences.getBool('seen');

   homeScreen = HomeScreen();
  
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await firebaseAuth.currentUser();
    if( user == null ){
      homeScreen = LoginScreen();
    }
  
  runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    checkAuthentication();
    

    
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  bool status = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  @override
  Widget build(BuildContext context) {
    Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange

    return new DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => new ThemeData(
        primarySwatch:Colors.deepOrange ,
        brightness: brightness,
      ),
       themedWidgetBuilder: (context, theme) {

        return MaterialApp(
          title: 'Flutter Demo',
          color: color1,
          debugShowCheckedModeBanner: false,
                   theme: theme,

          //initialRoute: 'home',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            'home': (context) => HomeScreen(),
            // When navigating to the "/second" route, build the SecondScreen widget.
                        'bottom': (context) => BottomNavigation(),

            'profile': (context) => ProfileScreen(),
            'waitingList': (context) => WaitingList(),
            'placesList': (context) => PlacesList(),
            //'placeScreen': (context) => PlaceScreen(),
            '/resetPassword': (context) => PasswordResset(),
            'offers': (context) => OffersScreen(),

            'settings': (context) => SettingsScreen(),
            '/signIn': (_) => LoginScreen(),
            '/signUp': (context) => RegisterScreen(),
          },
          home: Scaffold(
            body: new SplashScreen(
                seconds: 14,
                navigateAfterSeconds: BottomNavigation(),
                image: new Image.asset('images/pinpoint.png'),
                backgroundColor: color1,
                styleTextUnderTheLoader: new TextStyle(),
                photoSize: 100.0,
                loaderColor: color2),
          )
          // home: new HomeScreen(),
          );
          }
    );
  }

  checkAuthentication() async {
    user = await _auth.currentUser();
    if (user != null) {
      //it exists
      setState(() {
        status = true;
      });
    } else {
      //not exists
      setState(() {
        status = false;
      });
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

}
