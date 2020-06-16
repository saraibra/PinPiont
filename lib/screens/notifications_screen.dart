import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:pin_point/style/hexa_color.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Color color1 = HexColor("#333132"); //deep gray
  Color color2 = HexColor("#F15A29");
  bool _canVibrate = true;
  bool val = true;
  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;
  Future<void> checkUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      final snapShot = await Firestore.instance
          .collection('user_places')
          .document(user.uid)
          .get();
      if (snapShot.exists) {
        DocumentReference documentReference =
            Firestore.instance.collection("user_places").document(user.uid);
        documentReference.get().then((datasnapshot) {
          if (datasnapshot.exists) {
            val = datasnapshot.data['allowNotifications'];
          }
        });
      }
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
    init();

    super.initState();
  }

  init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? print("This device can vibrate")
          : print("This device cannot vibrate");
    });
  }

  void switchStatus(bool value) {
    setState(() {
      if (value) {
        val = true;

        _updateNotificationStatus(value);
      } else {
        val = false;
        _updateNotificationStatus(value);
      }
    });
  }

  _updateNotificationStatus(bool value) {
    Firestore.instance.collection('user_places').document(user.uid).updateData({
      'allowNotifications': value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: color1,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Allow notifications',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                trailing:
                    Switch(value: val, onChanged: (bool e) => switchStatus(e)),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Vibrate',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                trailing: Switch(
                    value: true,
                    onChanged: (_canVibrate) {
                      Vibrate.vibrate();
                    }),
              ),
              Divider(),
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Notifications time',
                      style: TextStyle(color: color1, fontSize: 20),
                    ),
                    DropdownButton<String>(
                        hint: Text(
                          'On time',
                          style: TextStyle(color: color1),
                        ),
                        iconEnabledColor: color1,
                        items: <String>['On time', '5 Min before time']
                            .map((String value) {
                          return new DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: color1),
                              ));
                        }).toList(),
                        onChanged: (value) {
                          if (value == '5 Min before time') {
                            Firestore.instance
                                .collection('user_places')
                                .document(user.uid)
                                .updateData({
                              'NotificationTime': false,
                            });
                            print('value');
                          } else {
                             Firestore.instance
                                .collection('user_places')
                                .document(user.uid)
                                .updateData({
                              'NotificationTime': true,
                            });
                            print('value22');
                          }
                        })
                  ],
                ),
                onTap: () {},
              ),
              Divider(),
            ],
          ),
        ));
  }
}
