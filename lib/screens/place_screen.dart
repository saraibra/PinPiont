import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:time/time.dart';

class PlaceScreen extends StatefulWidget {
  final String title;
  final int id;

  const PlaceScreen({Key key, @required this.title, @required this.id})
      : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
  TextEditingController _nameController;
  TextEditingController _phoneController;
  String name, phone;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: new IconButton(
            icon: FaIcon(
              FontAwesomeIcons.arrowLeft,
              color: Colors.white,
            ),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, 'placesList'),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("places")
                .where("id", isEqualTo: widget.id)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                final list = snapshot.data.documents;
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              list[index]['type'],
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: color1),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Number of people',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              list[index]['customerNumbers'].toString() +
                                  " / " +
                                  list[index]['capcity'].toString(),
                            ),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Waiting List',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: list[index]['capcityReached']
                                ? Text('Yes')
                                : Text('No'),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Location',
                                style: TextStyle(color: Colors.black),
                              )),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(list[index]['address']),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Phone',
                                style: TextStyle(color: Colors.black),
                              )),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(list[index]['phoneNumber']),
                          ),
                        ),
                        Divider(),
                        list[index]['capcityReached']
                            ? ListTile(
                                title: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Add to waiting list',
                                      style: TextStyle(color: Colors.black),
                                    )),
                                trailing: IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: color2,
                                      size: 36,
                                    ),
                                    onPressed: () async {
                                      FirebaseUser user;

                                      final FirebaseAuth _auth =
                                          FirebaseAuth.instance;

                                      user = await _auth.currentUser();
                                      showDialog(
                                          context: context,
                                          child: Dialog(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 250,
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "Waiting list form",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: color2,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      new TextFormField(
                                                        validator:
                                                            (String value) {
                                                          if (value.isEmpty) {
                                                            return 'Please enter your name !';
                                                          }
                                                        },
                                                        keyboardType:
                                                            TextInputType.text,
                                                        decoration:
                                                            KTextFieldDecoration
                                                                .copyWith(
                                                                    hintText:
                                                                        'Name'),
                                                        onSaved: (input) =>
                                                            name = input,
                                                      ),
                                                      new TextFormField(
                                                        validator:
                                                            (String value) {
                                                          if (value.isEmpty) {
                                                            return 'Please enter your phone number !';
                                                          }
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            KTextFieldDecoration
                                                                .copyWith(
                                                                    hintText:
                                                                        'Phone number '),
                                                        onSaved: (input) =>
                                                            phone = input,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          IconButton(
                                                              icon: Icon(
                                                                Icons.check,
                                                                color: color2,
                                                              ),
                                                              onPressed: () {
                                                                if (_formKey
                                                                    .currentState
                                                                    .validate()) {
                                                                  _formKey
                                                                      .currentState
                                                                      .save();
                                                                  try {
                                                                    int customerInWaiting =
                                                                        10;
                                                                    int waitTimeForPlace =
                                                                        5;
                                                                    int time =
                                                                        customerInWaiting *
                                                                            waitTimeForPlace;
                                                                    final DateTime
                                                                        finTime =
                                                                        time.minutes
                                                                            .fromNow;
                                                                    final DateTime
                                                                        logTime =
                                                                        DateTime
                                                                            .now();
                                                                    print(finTime
                                                                        .toString());

                                                                    Firestore
                                                                        .instance
                                                                        .collection(
                                                                            'user_places')
                                                                        .document(
                                                                            user.uid)
                                                                        .setData({
                                                                      'placeName':
                                                                          widget
                                                                              .title,
                                                                      'userName':
                                                                          name,
                                                                      'phoneNumber':
                                                                          phone,
                                                                      'customerInWaiting':
                                                                          customerInWaiting,
                                                                      'timeRemaining':
                                                                          time,
                                                                      'updatedTime':
                                                                          0,
                                                                      'logTime':
                                                                          logTime,
                                                                      'finTime':
                                                                          finTime,
                                                                      'placeId':
                                                                          widget
                                                                              .id,
                                                                      'userId':
                                                                          user.uid,
                                                                    });
                                                                    Fluttertoast.showToast(
                                                                        msg:
                                                                            "User is successfully added to waiting list",
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .CENTER,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        backgroundColor:
                                                                            color2,
                                                                        textColor:
                                                                            Colors
                                                                                .white,
                                                                        fontSize:
                                                                            16.0);
                                                                    Navigator.pop(
                                                                        context);
                                                                  } catch (e) {
                                                                    showError(e
                                                                        .message);
                                                                  }
                                                                }
                                                              }),
                                                          IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              color: color2,
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ));
                                    }),
                              )
                            : SizedBox()
                      ],
                    );
                  },
                );
              }
            }));
  }

  showError(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
