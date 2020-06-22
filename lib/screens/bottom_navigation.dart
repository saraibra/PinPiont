import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/models/persisten-bottom-nav-item.widget.dart';
import 'package:persistent_bottom_nav_bar/models/persistent-bottom-nav-bar-styles.widget.dart';
import 'package:persistent_bottom_nav_bar/models/persistent-nav-bar-scaffold.widget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/offers_screen.dart';
import 'package:pin_point/screens/settings_screen.dart';
import 'package:pin_point/screens/waiting_list.dart';
import 'package:pin_point/style/hexa_color.dart';

import 'home_screen.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  PersistentTabController _controller;
DateTime dateTime;

 Color color1 = HexColor("#1e1e1e");//deep gray
      Color color2  = HexColor("#F15A29"); 
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
     dateTime = 
  DateTime.now();
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
    // FirebaseMessagingScreen(),
OffersScreen(),
      WaitingList(),
      SettingsScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.home,size: 20,),
        title: (""),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.gifts),
        title: (""),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.listAlt),
        title: (""),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: (""),
         activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
      return PersistentTabView(
        controller: _controller,
        screens: _buildScreens(),
        items:
            _navBarsItems(), // Redundant here but defined to demonstrate for other than custom style
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        onItemSelected: (int) {
          setState(
              () {

            
              }); // This is required to update the nav bar if Android back button is pressed
        },
 itemCount: 4,
        navBarStyle:
            NavBarStyle.style3 // Choose the nav bar style with this property
        );
  }}