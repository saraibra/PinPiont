import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications extends StatefulWidget {
  LocalNotificationsState  localNotificationsState = new LocalNotificationsState();

  @override
  LocalNotificationsState createState() => LocalNotificationsState();
    void showNotifications(){
      localNotificationsState.showNotifications();
    }
}

class LocalNotificationsState extends State<LocalNotifications> {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
AndroidInitializationSettings androidInitializationSettings;
IOSInitializationSettings iosInitializationSettings;
InitializationSettings initializationSettings;

@override
  void initState() {
    super.initState();
  }
  void initializing()async{
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification:onDidReceiveLocalNotification);
 initializationSettings = InitializationSettings(androidInitializationSettings, iosInitializationSettings);
await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
  }
  void showNotifications()async{
  await notification();
  }
  Future<void> notification()async{
    var timeDelayed = DateTime.now().add(Duration(seconds: 5) );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'channel_Id', 
      'channel title', 
      'channel body',
      priority: Priority.High,
      importance: Importance.Max,
      ticker: 'PinPoint'
      );
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails, iosNotificationDetails);
await flutterLocalNotificationsPlugin.schedule(0, 'PinPoint', 'body',timeDelayed, notificationDetails);
  }
  Future onSelectNotification(String payload){
    if(payload != null){
// set navigator to go waiting screen
    }
  }

  Future onDidReceiveLocalNotification(int id ,String title ,String body,String payload)async
  {
return CupertinoAlertDialog(
  title: Text(title),
  content: Text(body),
  actions: <Widget>[
    CupertinoDialogAction(
      isDefaultAction: true,
      onPressed: (){},
      child: Text('Okay'))
  ],
);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}