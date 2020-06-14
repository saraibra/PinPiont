import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
   Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); 
     bool _canVibrate = true;
init() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
      _canVibrate
          ? print("This device can vibrate")
          : print("This device cannot vibrate");
    });
  }

@override
  initState() {
    super.initState();
    init();
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
                trailing: Switch(value: true, onChanged: (bool switchStatus){}),
          ),
          Divider(),
          ListTile(
            title: Text(
                  'Vibrate',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                trailing: Switch(value: true, onChanged: ( _canVibrate){
                                        Vibrate.vibrate();

                }),
          ),
          Divider(),
            ListTile(
            title: Text(
                  'Notifications tone',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                onTap: (){
                  FlutterRingtonePlayer.play(
  android: AndroidSounds.notification,
  ios: IosSounds.glass,
  looping: true, // Android only - API >= 28
  volume: 0.1, // Android only - API >= 28
  asAlarm: false, // Android only - all APIs
);

                },
          ),
          Divider(),

        ],
      ),
    )
    );
  }
}