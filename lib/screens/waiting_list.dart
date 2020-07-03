import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/login_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class WaitingList extends StatefulWidget {
  final bool status;
  final bool waitingStatus;
  final FirebaseUser user;
  const WaitingList({Key key, this.status, this.waitingStatus, this.user})
      : super(key: key);
  @override
  _WaitingListState createState() => _WaitingListState();
}

class _WaitingListState extends State<WaitingList> {
  FirebaseUser user;
  bool status = false;
  Stream<QuerySnapshot> stream2;
  int time;
  int difference;
  int timeRemaining;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double timeRemainingPercentage;
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
 bool waiting;
  Color selectedColor = HexColor("#F15A29");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;

  @override
  void initState() {
    super.initState();
    buildWaitingList();
    new Timer.periodic(
        Duration(seconds: 60),
        (Timer t) => setState(() {
              showWaitingList();
            }));
  }

  Future buildWaitingList() async {
    user = await _auth.currentUser();
    if (user != null) {
      final snapShot = await Firestore.instance
          .collection('user_places')
          .document(user.uid)
          .get();
           Firestore.instance
          .collection("users")
          .document(user.uid)
          .get()
          .then((DocumentSnapshot) {
            setState(() {
                      waiting = DocumentSnapshot.data['waitingList'];

            });
  });
      if (snapShot.exists) {
        stream2 = Firestore.instance
            .collection("users")
            .document(user.uid)
            .collection("user_places")
            .snapshots();

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
    } else {
      //not exists
      setState(() {
        status = false;
      });
    }
  }

  Widget showTimeRemaining(int timeRemainingNumber) {
    if (timeRemainingNumber == 0) {
      timeRemainingNumber = 2;
    } else if (timeRemainingNumber == 100) {
      timeRemainingNumber = 98;
    }
    return SizedBox(
      width: 200,
      child: StepProgressIndicator(
        totalSteps: 100,
        currentStep: timeRemainingNumber,
        // stepSize: 10,
        selectedColor: color2,
        unselectedColor: Colors.grey,
        padding: 0,
        size: 10,
        roundedEdges: Radius.circular(16),
        // selectedStepSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
              child: Text(
            'WAITING LIST',
          )),
          backgroundColor: color1),
      body: (widget.status)
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: showWaitingList(),
            )
          : Container(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    '''Sign up or sign in to add and see
 your waiting lists.''',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              )),
            ),
    );
  }

  Widget showWaitingList() {
    return (!widget.waitingStatus || waiting == false)
        ? Container(
            child: Center(
                child: Text(
              '''You currently have
 no waiting lists!''',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            )),
          )
        : Center(
            child: StreamBuilder(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.user.uid)
                    .collection("user_places")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          var ref = Firestore.instance
                              .collection("users")
                              .document(user.uid)
                              .collection("user_places")
                              .getDocuments();
                          final list = snapshot.data.documents;
                          for (int i = 0;
                              i < snapshot.data.documents.length;
                              i++) {
                            time = list[index]['timeRemaining'];
                            final logTime = list[index]['logTime'].toDate();
                            final finTime = list[index]['finTime'].toDate();

                            final DateTime timeNow = DateTime.now();

                            var nowTimeSeconds =
                                timeNow.toUtc().millisecondsSinceEpoch;
                            var finTimeSeconds =
                                finTime.toUtc().millisecondsSinceEpoch;
                            if (finTimeSeconds > nowTimeSeconds) {
                              difference =
                                  timeNow.difference(logTime).inMinutes;
                              timeRemaining = time - difference;
                              timeRemainingPercentage =
                                  (difference * 100 / time);
                            } else {
                              timeRemainingPercentage = 100;

                              difference = 0;
                              timeRemaining = 0;
                            }
                            /* ref.then((v) => Firestore.instance
                                    .collection("users")
                                    .document(user.uid)
                                    .collection("user_places")
                                    .document(v.documents[index].documentID)
                                    .updateData({
                                  'updatedTime': timeRemaining,
                                }));*/
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 8),
                                  // child: Container(

                                  child: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 16),
                                          child: Container(
                                            width: double.infinity,
                                            height: 190,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 16),
                                                    child: Text(
                                                      list[index]['logTime']
                                                          .toDate()
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                          color: color1),
                                                    ),
                                                  ),
                                                  Text(
                                                    list[index]['placeName'],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        color: color1),
                                                  ),
                                                  Text(
                                                    list[index]['placeType'],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: color1),
                                                  ),
                                                  SizedBox(height: 16),
                                                  showTimeRemaining(
                                                      timeRemainingPercentage
                                                          .toInt()),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16),
                                                    child: (timeRemaining == 0)
                                                        ? Text(
                                                            'Time is up',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: color1),
                                                          )
                                                        : Row(
                                                            children: <Widget>[
                                                              Text(
                                                                timeRemaining
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        color1),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            4.0),
                                                                child: Text(
                                                                    'mins remaining',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontSize:
                                                                            14,
                                                                        color:
                                                                            color1)),
                                                              )
                                                            ],
                                                          ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        list[index][
                                                                'customerInWaiting']
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: color1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 4.0),
                                                        child: Text(
                                                            'people in the queue',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                color: color1)),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))),
                                  // ),
                                )
                              ],
                            ),
                          );

                          /*  return Center(
                                child: Container(
                                    color: Colors.white,
                                    child: Column(children: <Widget>[
                                      ListTile(
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 48.0,left: 48,right: 48),
                                          
                                            child: Text(
                                              list[index]['placeName'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: color2),
                                            ),
                                         
                                        ),
                                      ),
                                      showTimeRemaining(
                                          timeRemainingPercentage.toInt()),
                                      ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 48.0, top: 16),
                                          child: difference > 0
                                              ? Row(
                                                  children: <Widget>[
                                                    Text(
                                                      list[index]['updatedTime']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: color1),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text('Min remaining',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: color1)),
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      ListTile(
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 48.0),
                                          child: difference > 0
                                              ? Row(
                                                  children: <Widget>[
                                                    Text(
                                                      list[index][
                                                              'customerInWaiting']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: color1),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Text(
                                                          'people in the queue',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: color1)),
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                        ),
                                      ),
                                    ])),
                              );
                            */
                        });
                  }
                }),
          );
  }
}
