import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';



class WaitingList extends StatefulWidget {
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
  
      Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;



  @override
  void initState() {
    super.initState();
    buildWaitingList();

    initializing();

    showNotifications();
  }

  Future buildWaitingList() async {
    user = await _auth.currentUser();
    if (user != null) {
      final snapShot = await Firestore.instance
          .collection('user_places')
          .document(user.uid)
          .get();
      if (snapShot.exists) {
        stream2 = Firestore.instance
            .collection("user_places")
            .where('userId', isEqualTo: user.uid)
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

  Widget showTimeRemaining(int timeRemaining, int totalTimeRemaining) {
    return CircularStepProgressIndicator(
      totalSteps: totalTimeRemaining,
      currentStep: timeRemaining,
      stepSize: 10,
      selectedColor: Colors.greenAccent,
      unselectedColor: Colors.grey[200],
      padding: 0,
      width: 150,
      height: 150,
      selectedStepSize: 15,
    );

    /*  new CircularPercentIndicator(
                                      radius: 130.0,
                                      animation: true,
                                      animationDuration: 6000,
                                      lineWidth: 15.0,
                                      percent: 1.0,
                                      center: new Text(
                                        "5"+" "+" Min",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                      circularStrokeCap: CircularStrokeCap.butt,
                                      backgroundColor: Colors.yellow,
                                      progressColor: Colors.red,
                                    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WAITING LIST'), backgroundColor: color1),
      body: status
          ? Center(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("user_places")
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return CircularProgressIndicator();
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      final list = snapshot.data.documents;
                      time = list[0]['timeRemaining'];
                      final logTime = list[0]['logTime'].toDate();
                      final finTime = list[0]['finTime'].toDate();
                      final DateTime timeNow = DateTime.now();

                      var nowTimeSeconds =
                          timeNow.toUtc().millisecondsSinceEpoch;
                      var finTimeSeconds =
                          finTime.toUtc().millisecondsSinceEpoch;
                      if (finTimeSeconds > nowTimeSeconds) {
                        difference = timeNow.difference(logTime).inMinutes;
                        timeRemaining = time - difference;
                      } else {
                        difference = 0;
                        timeRemaining = 0;
                      }
                     

                      Firestore.instance
                          .collection("user_places")
                          .document(user.uid)
                          .updateData({
                        'updatedTime': timeRemaining,
                      });
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return Center(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: color2,
                                  child: Column(children: <Widget>[
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 32.0),
                                        child: Text(
                                          list[index]['placeName'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    difference==0?SizedBox(
  width: 250.0,
  child: ScaleAnimatedTextKit(
    
    text: [
      "Time",
      "Out",
      ],
    textStyle: TextStyle(
        fontSize: 70.0,
        fontFamily: "Canterbury"
    ),
    textAlign: TextAlign.start,
    alignment: AlignmentDirectional.topStart // or Alignment.topLeft
  ),
):
                                    showTimeRemaining(difference, time),
                                    ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24.0, top: 16),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              list[index]['updatedTime']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text('Min remaining',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24.0, top: 4),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              list[index]['customerInWaiting']
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text('people in the queue',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ])),
                            );
                          });
                    }
                  }),
            )
          : Container(
              child: Center(
                  child: Text(
                'You dont have any waiting list',
                style: TextStyle(fontSize: 18, color: color1),
              )),
            ),
    );
  }

  void initializing() async {
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void showNotifications() async {
    await notification();
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  }

  Future<void> notification() async {
    var time = Time(2, 33, 0);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_ID',
      'channel title',
      'channel body',
      priority: Priority.High,
      importance: Importance.Max,
      ticker: 'PinPoint',
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, "PinPoint", "PinPoint", time, notificationDetails);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('Ok'),
          isDefaultAction: true,
          onPressed: () {
            print("notification pressed");
          },
        )
      ],
    );
  }
}
