import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/screenutil.dart';
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

  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29");
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;
    bool waitingStatus = false;
     
  Future<void> checkUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      //it exists
      setState(() {
        status = true;
         Firestore.instance
          .collection("users")
          .document(user.uid)
          .get()
          .then((DocumentSnapshot) {
            setState(() {
                      waitingStatus = DocumentSnapshot.data['waitingList'];

            });
      });
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
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    dateTime = DateTime.now();
        checkUser();

  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      // FirebaseMessagingScreen(),
   
      OffersScreen(status: status,),
      WaitingList(status:status,waitingStatus: waitingStatus,user: user,),
      SettingsScreen(status: status,),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        titleFontSize: 10,
        contentPadding: 0,
        icon: Icon(
          SimpleLineIcons.home
        ),
        title: ("Home"),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
         titleFontSize: 10,
        contentPadding: 5,
        icon:  Icon(
          SimpleLineIcons.present
        ),
        title: ("Rewards"),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
         icon: Icon(
          SimpleLineIcons.list
        ),
         titleFontSize: 10,
        contentPadding: 10,
        title: ("Waiting List"),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
      PersistentBottomNavBarItem(
         icon: Icon(
          SimpleLineIcons.settings
        ),
         titleFontSize: 10,
        contentPadding: 10,
        title: ("Settings"),
        activeColor: color2,
        inactiveColor: color1,
        isTranslucent: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) 
  {

    return  PersistentTabView(
        controller: _controller,
        screens: _buildScreens(),
        items:
            _navBarsItems(), // Redundant here but defined to demonstrate for other than custom style
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        iconSize: 20,
        navBarStyle:
            NavBarStyle.style3, // Choose the nav bar style with this property
        bottomPadding: 14,
        showElevation: true,
        navBarCurve: NavBarCurve.upperCorners,
        handleAndroidBackButtonPress: true,
        onItemSelected: (int) {
          setState(
              () {}); // This is required to update the nav bar if Android back button is pressed
        },
        itemCount: 4,
      
    );
  }
}
