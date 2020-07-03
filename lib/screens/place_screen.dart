import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/size_config.dart';
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
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  Color color3 = HexColor("#c0c0c0");
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name, phone;

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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text(widget.title)),
          backgroundColor: color1,
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
                        Container(
                          height: SizeConfig.screenHeight / 11,
                          child: ListTile(
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
                        ),
                        Container(
                          height: SizeConfig.screenHeight / 8,
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Number of People',
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                          ),
                        ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        Container(
                          height: SizeConfig.screenHeight / 8,
                          child: ListTile(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        Container(
                          height: SizeConfig.screenHeight / 8,
                          child: ListTile(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6),
                          child: Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        Container(
                          height: SizeConfig.screenHeight / 8,
                          child: list[index]['capcityReached']
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 16, right: 8),
                                  child: ListTile(
                                    title: Text(
                                      'Add to waiting list',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    trailing: IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: color2,
                                          size: 36,
                                        ),
                                        onPressed: status
                                            ? () async {
                                                user =
                                                    await _auth.currentUser();
                                                return showDialog<AlertDialog>(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0))),
                                                                          actionsPadding: EdgeInsets.only(
                                                                  bottom: 16),
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  top: 32),
                                                          content: Column(
                                                                mainAxisSize: MainAxisSize.min,

                                                            children: <Widget>[
                                                              Container(
                                                                width: SizeConfig
                                                                        .screenWidth -
                                                                    64,
                                                               
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          24.0),
                                                                  child: Container(
                                                                  
                                                                    child: Form(
                                                                      key: _formKey,
                                                                      child: Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            "WAITING LIST FORM",
                                                                            textAlign: TextAlign.center,
                                                                            style: TextStyle(
                                                                                fontSize:
                                                                                    18,
                                                                                color:
                                                                                    color2,
                                                                                fontWeight:
                                                                                    FontWeight.bold),
                                                                          ),
                                                                          
                                                                          Container(
                                                                           
                                                                              child:
                                                                                  SingleChildScrollView(
                                                                                child:
                                                                                    Column(children: <Widget>[
                                                                                  new TextFormField(
                                                                                    validator: (String value) {
                                                                                      if (value.isEmpty) {
                                                                                        return 'Invalid name !';
                                                                                      }
                                                                                    },
                                                                                    keyboardType: TextInputType.text,
                                                                                    decoration: KTextFieldDecoration.copyWith(hintText: 'Name'),
                                                                                    onSaved: (input) => name = input,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  TextFormField(
                                                                                    validator: (String value) {
                                                                                      if (value.isEmpty) {
                                                                                        return 'Invalid phone number!';
                                                                                      }
                                                                                    },
                                                                                    keyboardType: TextInputType.number,
                                                                                    decoration: KTextFieldDecoration.copyWith(hintText: 'Phone number '),
                                                                                    onSaved: (input) => phone = input,
                                                                                  ),
                                                                                ]),
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      
                                                                      right:
                                                                          16.0),
                                                              child: IconButton(
                                                                  icon: Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        color2,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    if (_formKey
                                                                        .currentState
                                                                        .validate()) {
                                                                      _formKey
                                                                          .currentState
                                                                          .save();
                                                                      try {
                                                                        int customerInWaiting =
                                                                            list[index]['customerInWaiting'];

                                                                        int waitTimeForPlace =
                                                                            list[index]['waitTimeForPlace'];

                                                                        int time =
                                                                            customerInWaiting *
                                                                                waitTimeForPlace;
                                                                        final DateTime
                                                                            finTime =
                                                                            time.minutes.fromNow;
                                                                        final DateTime
                                                                            logTime =
                                                                            DateTime.now();
                                                                        print(finTime
                                                                            .toString());
                                                                        var logTimeSeconds = logTime
                                                                            .toUtc()
                                                                            .millisecondsSinceEpoch;
                                                                        Firestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .document(user.uid)
                                                                            .updateData({
                                                                          'waitingList':
                                                                              true,
                                                                        });
                                                                        Firestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .document(user.uid)
                                                                            .collection('user_places')
                                                                            .document(logTimeSeconds.toString())
                                                                            .setData({
                                                                          'placeName':
                                                                              widget.title,
                                                                          'placeType':
                                                                              list[index]['type'],
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
                                                                              widget.id,
                                                                          'userId':
                                                                              user.uid,
                                                                          'allowNotifications':
                                                                              true,
                                                                          'NotificationTime':
                                                                              true,
                                                                        });

                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                "User is successfully added to the waiting list",
                                                                            toastLength: Toast
                                                                                .LENGTH_LONG,
                                                                            gravity: ToastGravity
                                                                                .CENTER,
                                                                            timeInSecForIosWeb:
                                                                                3,
                                                                            backgroundColor:
                                                                                color2,
                                                                            textColor:
                                                                                Colors.white,
                                                                            fontSize: 14.0);

                                                                        Navigator.pop(
                                                                            context);
                                                                      } catch (e) {
                                                                        showError(
                                                                            e.message);
                                                                      }
                                                                    }
                                                                  }),
                                                            ),
                                                            SizedBox(
                                                              width: 130,
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                color: status
                                                                    ? color2
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                            )
                                                          ]);
                                                    });
                                              }
                                            : Fluttertoast.showToast(
                                                msg:
                                                    '''Please sign in order to add you in
   the waiting list''',
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 3,
                                                backgroundColor: color2,
                                                textColor: Colors.white,
                                                fontSize: 14.0)),
                                  ))
                              : SizedBox(),
                        )
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

  _displaySnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: color3),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
