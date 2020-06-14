import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
class FirebaseMessagingScreen extends StatefulWidget {
  FirebaseMessagingScreen():super();
String title;
  @override
  _FirebaseMessagingScreenState createState() => _FirebaseMessagingScreenState();
}

class _FirebaseMessagingScreenState extends State<FirebaseMessagingScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken) {
 print(deviceToken);
    });
  }
  @override
  void initState() {
_getToken();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}


