import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_point/style/hexa_color.dart';

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  FirebaseUser user;
  int points;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    checkUser();

    super.initState();
  }

  bool status = false;
  Future<void> checkUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      setState(() async {
        final snapShot = await Firestore.instance
            .collection('users')
            .document(user.uid)
            .get();
        if (snapShot.exists) {
          DocumentReference documentReference =
              Firestore.instance.collection("users").document(user.uid);
          documentReference.get().then((datasnapshot) {
            if (datasnapshot.exists) {
              points = datasnapshot.data['points'];
            }
          });
        }
        //it exists

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('REWARDS'),
        backgroundColor: color1,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Text(
            'YOU HAVE',
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
          Text(
            points.toString(),
            style: TextStyle(fontSize: 28, color: color2),
          ),
          Text(
            'Pinpoints',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(
            height: 32,
          ),
           Text('MY SPENDINGS',
   style: TextStyle(
     fontSize: 24,
     color: color2
   ),
   ),
    Container(
      height: 120,
      width: 200,
        decoration: new BoxDecoration(
           borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(48.0),
                                      topRight: const Radius.circular(48.0),
                                      bottomLeft: const Radius.circular(48.0),
                                      bottomRight: const Radius.circular(48.0),
                                    ),
          image: new DecorationImage(
              image: new AssetImage("images/reward.jpg"),
              fit: BoxFit.fill,
          )
        )
    ),
     SizedBox(
            height: 32,
          ),
           Text('SCAN YOUR RECEIPT',
   style: TextStyle(
     fontSize: 24,
     color: color1
   ),
   ),
  FloatingActionButton(
    backgroundColor: color2,
                child: FaIcon(
                  FontAwesomeIcons.cameraRetro,
                  color: Colors.white,
                ),
     
     onPressed: (){})
        ],
      )
          /* Text('You dont have any points yet',
    style: TextStyle(
      color: color2,
      fontSize: 24
    ),
    
    ),*/
          ),
    );
  }
}
