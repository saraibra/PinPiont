
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:splashscreen/splashscreen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:flutter/services.dart';
 Widget homeScreen;
void main()async{ 
   // ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    //connectionStatus.initialize();
 
  
  runApp(MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 
  

  @override
  void initState() {
    super.initState();


    

    
  }


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
          title: 'PinPoint',
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
                seconds: 10,
                navigateAfterSeconds: BottomNavigation(),
                image: new Image.asset('images/logo.png'),
                backgroundColor: Colors.white,
                styleTextUnderTheLoader: new TextStyle(),
                photoSize: 100.0,
                loaderColor: color2),
          )
          // home: new HomeScreen(),
          );
          }
    );
  }


 

}
