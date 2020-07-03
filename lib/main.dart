import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_point/screens/bottom_navigation.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/login_screen.dart';
import 'package:pin_point/screens/password_reset.dart';
import 'package:pin_point/screens/places_list.dart';
import 'package:pin_point/screens/profile_screen.dart';
import 'package:pin_point/screens/register.dart';
import 'package:pin_point/screens/settings_screen.dart';
import 'package:pin_point/screens/waiting_list.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
//import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';

void main() => runApp(
      DevicePreview(
        // enabled: !kReleaseMode,
        builder: (context) => MyApp(),
      ),
    );

/*void main() {
WidgetsFlutterBinding.ensureInitialized();
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  .then((_) {
runApp(MyApp());
});
}*/

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color color1 = HexColor("#1e1e1e"); // gray
  Color color2 = HexColor("#F15A29"); //orange

  @override
  Widget build(BuildContext context) {
    // Set portrait orientation
    //  SizeConfig().init(context);

    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.deepOrange,
              fontFamily: 'Montserrat',
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
              title: 'PinPoint',
              color: color1,
              debugShowCheckedModeBanner: false,
              theme: theme,
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
                // 'offers': (context) => OffersScreen(),

                'settings': (context) => SettingsScreen(),
                '/signIn': (_) => LoginScreen(),
                '/signUp': (context) => RegisterScreen(),
              },
              home:Splash(),
              /* Scaffold(
                  backgroundColor: color1,
                  body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 100,
                        ),
                        Center(
                          child: Container(
                            height: 250,
                            child: new SplashScreen(
                                seconds: 10,
                                navigateAfterSeconds: FutureBuilder<
                                        FirebaseUser>(
                                    future: FirebaseAuth.instance.currentUser(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<FirebaseUser> snapshot) {
                                      if (snapshot.hasData) {
                                        FirebaseUser user = snapshot
                                            .data; // this is your user instance
                                        /// is because there is user already logged
                                        return BottomNavigation();
                                      }

                                      /// other way there is no user logged.
                                      return LoginScreen();
                                    }),
                                image: new Image.asset('images/icon5.png'),
                                backgroundColor: color1,
                                styleTextUnderTheLoader: new TextStyle(),
                                photoSize: 40.0,
                                loaderColor: color1),
                          ),
                        ),
                      ]))
              // home: new HomeScreen(),*/
              );
        });
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    new Future.delayed(
        const Duration(seconds: 10),
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FutureBuilder<FirebaseUser>(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<FirebaseUser> snapshot) {
                      if (snapshot.hasData) {
                        FirebaseUser user =
                            snapshot.data; // this is your user instance
                        /// is because there is user already logged
                        return BottomNavigation();
                      }

                      /// other way there is no user logged.
                      return LoginScreen();
                    }),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
      Color color1 = HexColor("#1e1e1e"); // gray

    return new Scaffold(
      backgroundColor: color1,
      body: Center(
        child: Container(
          child: new Image.asset(
            'images/icon5.png',
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
            width: 100.0,
            height:100,
          ),
        ),
      ),
    );
  }
}
