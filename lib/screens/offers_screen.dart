import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/login_screen.dart';
import 'package:pin_point/screens/spending_screen.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:path/path.dart';
import 'package:pin_point/utilities/size_config.dart';

class OffersScreen extends StatefulWidget {
  final bool status;

  const OffersScreen({Key key, @required this.status}) : super(key: key);
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  FirebaseUser user;
  int points = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    checkUser();

    super.initState();
  }

  Future<void> checkUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      final snapShot =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (snapShot.exists) {
        DocumentReference documentReference =
            Firestore.instance.collection("users").document(user.uid);
        documentReference.get().then((datasnapshot) {
          if (datasnapshot.exists) {
            points = datasnapshot.data['points'];
            print(points.toString());
          }
        }
            //it exists

            );
        setState(() {
          //  widget.status = true;
        });
      } else {
        //not exists
        setState(() {
          //status = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('REWARDS')),
        backgroundColor: color1,
      ),
      body: widget.status
          ? SingleChildScrollView(
              
                child: Center(
                    child: Padding(
                padding: const EdgeInsets.only(top: 32.0,bottom:16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      Container(
                        height: SizeConfig.screenHeight / 7,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'YOU HAVE',
                              style: TextStyle(fontSize: 16, color: color1),
                            ),
                            Text(
                              points.toString(),
                              style: TextStyle(
                                  fontSize: 32,
                                  color: color2,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'PIN POINTS',
                              style: TextStyle(
                                fontSize: 14,
                                color: color2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Container(
                        height: 2 * SizeConfig.screenHeight / 6,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'MY SPENDINGS',
                              style: TextStyle(
                                fontSize: 18,
                                color: color1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              onTap: () {
                                pushNewScreen(
                                  context,
                                  screen: SpendingScreen(),
                                  platformSpecific:
                                      false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                                  withNavBar:
                                      true, // OPTIONAL VALUE. True by default.
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Container(
                        height: 8+ SizeConfig.screenHeight / 4,
                                    width: double.infinity,
                                    decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(24.0),
                                          topRight: const Radius.circular(24.0),
                                          bottomLeft: const Radius.circular(24.0),
                                          bottomRight:
                                              const Radius.circular(24.0),
                                        ),
                                        image: new DecorationImage(
                                          image: new AssetImage(
                                              "images/reward.jpeg"),
                                          fit: BoxFit.fill,
                                        ))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: SizeConfig.screenHeight/6,
                        child: Column(
                          children: <Widget>[
                                    Text(
                        'SCAN YOUR RECEIPT',
                        style: TextStyle(
                          fontSize: 14,
                          color: color1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            var image = await ImagePicker.pickImage(
                                source: ImageSource.camera);
                            setState(() {
                              _image = image;
                            });
                            if (image != null) {
                              uploadPic(context);
                            }
                          },
                          child: Container(
                            child: new Image.asset(
                              'images/scan.png',
                              height: 60.0,
                              width: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                 
                          ],
                        ),
                      ),
             ],
                ),
                    )),
            
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: GestureDetector(
                    onTap: () {
                      pushNewScreen(
                        context,
                        screen: LoginScreen(),
                        platformSpecific:
                            false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                      );
                    },
                    child: Text(
                      '''Sign in or sign up to
 receive your rewards.''',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )),
    );
  }

  showImageDialog(BuildContext context, String uri) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 350.0,
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.only(left: 30.0, top: 24, right: 30.0),
                      child: Center(
                          child: Text(
                        'Do you want to take another picture?',
                        textAlign: TextAlign.center,
                      ))),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 32.0, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                          color: color2,
                          child: Text(
                            'YES',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          onPressed: () async {
                            var image = await ImagePicker.pickImage(
                                source: ImageSource.camera);
                            setState(() {
                              _image = image;
                            });
                            if (image != null) {
                              String fileName = basename(_image.path);
                              StorageReference storageReference =
                                  FirebaseStorage.instance
                                      .ref()
                                      .child(fileName);
                              StorageUploadTask storageUploadTask =
                                  storageReference.putFile(_image);
                              StorageTaskSnapshot taskSnapshot =
                                  await storageUploadTask.onComplete;
                              String uri2 =
                                  await taskSnapshot.ref.getDownloadURL();
                              final QuerySnapshot result = await Firestore
                                  .instance
                                  .collection("users")
                                  .document(user.uid)
                                  .collection("userReceipt")
                                  .where('receiptImage', isEqualTo: uri)
                                  .getDocuments();
                              var list2 = result.documents;
                              print(list2[0].documentID.toString());

                              Firestore.instance
                                  .collection('users')
                                  .document(user.uid)
                                  .collection('userReceipt')
                                  .document(list2[0].documentID)
                                  .updateData({
                                'receiptImage': uri,
                                'hasAnotherImage': true,
                                'anotherImageUri': uri2,
                              });
                              Navigator.pop(context);
                            }
                          }),
                    ),
                    SizedBox(
                      width: 100,
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        color: color2,
                        child: Text(
                          'NO',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future uploadPic(BuildContext context) async {
    String fileName = basename(_image.path);
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    String uri = await taskSnapshot.ref.getDownloadURL();

    Firestore.instance
        .collection('users')
        .document(user.uid)
        .collection('userReceipt')
        .document()
        .setData({
      'receiptImage': uri,
      'hasAnotherImage': false,
      'anotherImageUri': '',
    });
    setState(() {
      showImageDialog(context, uri);
    });
  }

  void navigateToSignInScreen() {}
}
