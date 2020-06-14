import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:share/share.dart';

class PinpointDrawer extends StatefulWidget {
  @override
  _PinpointDrawerState createState() => _PinpointDrawerState();
}

class _PinpointDrawerState extends State<PinpointDrawer> {
  Color color1 = HexColor("#223469");

  Color color2 = HexColor("#f05a2b");
  String uid;
  FirebaseUser user;

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool status = false;
  Future<void> getUserUid() async {
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
          getUserUid();



    super.initState();
  }

  Widget getHeader() {
              getUserUid();

    return  StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
       
            final list = snapshot.data;
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return CircularProgressIndicator();

                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  foregroundColor: color1,
                  child: ClipOval(
                    child: SizedBox(
                        width: 90,
                        height: 90,
                        child: (list['profileImage'] != null)
                            ? Image.network(list['profileImage'],
                                fit: BoxFit.fill)
                            : Image.asset('images/user.png')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        snapshot.data['firstName'],
                        style: TextStyle(fontSize: 14, color: color1),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        snapshot.data['lastName'],
                        style: TextStyle(fontSize: 14, color: color1),
                      )
                    ],
                  ),
                )
              ],
            );
                            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(decoration: BoxDecoration(), child: getHeader()),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'home');
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.gifts),
            title: Text("Offers"),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'offers');
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.listAlt),
            title: Text("Waiting List"),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'waitingList');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pushReplacementNamed(context, 'settings');
            },
          ),
          Divider(),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.shareAlt),
            title: Text("Share"),
            onTap: () {
              final RenderBox box = context.findRenderObject();
              Share.share('Share',
                  sharePositionOrigin:
                      box.localToGlobal(Offset.zero) & box.size);
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.signOutAlt),
            title: Text("Sign out"),
            onTap: () async {
              final _firebaseAuth = FirebaseAuth.instance;
              await _firebaseAuth.signOut();
              Navigator.pushReplacementNamed(context, '/signIn');
            },
          ),
        ],
      ),
    );
  }
}
