import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/help_screen.dart';
import 'package:pin_point/screens/notifications_screen.dart';
import 'package:pin_point/screens/profile_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_point/screens/login_screen.dart';
import 'package:pin_point/utilities/rounded_button.dart';
import 'package:share/share.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:dynamic_theme/theme_switcher_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final status;

  const SettingsScreen({Key key, this.status}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  bool isSelected = false;
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;
  Future<void> checkUser() async {
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

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  void showChooser() {
    showDialog<void>(
        context: context,
        builder: (context) {
          return BrightnessSwitcherDialog(
            onSelectedTheme: (brightness) {
              DynamicTheme.of(context).setBrightness(brightness);
            },
          );
        });
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }

  void changeColor() {
    DynamicTheme.of(context).setThemeData(ThemeData(
        primaryColor: Theme.of(context).primaryColor == Colors.indigo
            ? Colors.red
            : Colors.indigo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'SETTINGS',
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: color1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    widget.status
                        ? Column(children: <Widget>[
                            ListTile(
                              leading: Icon(
                                SimpleLineIcons.user,
                                color: color2,
                                size: 22,
                              ),
                              title: Text(
                                'Account',
                                style: TextStyle(color: color1, fontSize: 18),
                              ),
                              subtitle: Text(
                                'Update account',
                                style: TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                pushNewScreen(
                                  context,
                                  screen: ProfileScreen(),
                                  platformSpecific:
                                      false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                );
                              },
                            ),
                            Divider(),
                          ])
                        : Container(),
                    Column(children: <Widget>[
                      ListTile(
                        onTap: () {
                          pushNewScreen(
                            context,
                            screen: NotificationsScreen(),
                            platformSpecific:
                                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                          );
                        },
                        leading: Icon(
                          SimpleLineIcons.bell,
                          color: color2,
                          size: 22,
                        ),
                        title: Text(
                          'Notifications',
                          style: TextStyle(color: color1, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Manage notifications & tones',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Divider(),
                    ]),
                    ListTile(
                        leading: Icon(
                          SimpleLineIcons.question,
                          color: color2,
                          size: 22,
                        ),
                        title: Text(
                          'Help',
                          style: TextStyle(color: color1, fontSize: 18),
                        ),
                        subtitle: Text(
                          'FAQ ,Contact & App info',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          pushNewScreen(
                            context,
                            screen: HelpScreen(),
                            platformSpecific:
                                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                            withNavBar:
                                true, // OPTIONAL VALUE. True by default.
                          );
                        }),
                    Divider(),
                    /*  ListTile(
                            leading: Icon(
                              SimpleLineIcons.globe,
                              color: color2,
                                      size: 22,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Language",
                                  style: TextStyle(
                                    color: color1,
                                    fontSize: 18,
                                  ),
                                ),
                                DropdownButton<String>(
                                    hint: Text(
                                      'English',
                                      style: TextStyle(color: color1),
                                    ),
                                    iconEnabledColor: color1,
                                    items:
                                        <String>['English', 'عربى'].map((String value) {
                                      return new DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(color: color1,
                                            
                                            fontSize: 14),
                                          ));
                                    }).toList(),
                                    onChanged: (_) {})
                              ],
                            ),
                          ),
                          Divider(),*/
                    ListTile(
                      leading: Icon(
                        SimpleLineIcons.share,
                        color: color2,
                        size: 22,
                      ),
                      title: Text(
                        'Share',
                        style: TextStyle(color: color1, fontSize: 18),
                      ),
                      onTap: () {
                        final RenderBox box = context.findRenderObject();
                        Share.share('',
                            sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Hero(
                      tag: 'login',
                      child: RoundedButton(
                        color: color2,
                        text: 'SIGN OUT',
                        onPress: () async {
                          final googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();
                          final facebookLogin = FacebookLogin();
                          await facebookLogin.logOut();
                          final _firebaseAuth = FirebaseAuth.instance;
                          await _firebaseAuth.signOut();
                          pushNewScreen(
                            context,
                            screen: LoginScreen(
                            ),
                            platformSpecific:
                                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                          );
                        },
                      ))
              
            ),
          ],
        ),
      ),
    );
  }
}
