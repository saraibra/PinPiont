import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/app_info.dart';
import 'package:pin_point/screens/contact_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29");
  void _showErrorSnackBar() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Oops... the URL couldn\'t be opened!'),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
            ScreenUtil.init(width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text('HELP')),
          backgroundColor: color1,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                  leading: Icon(
                    SimpleLineIcons.question,
                    color: color2,
                    size: 22,
                  ),
                  title: Text(
                    'FAQS',
                    style: TextStyle(color: color1, fontSize: 20),
                  ),
                  onTap: () {}),
              Divider(),
              ListTile(
                leading: Icon(
                  SimpleLineIcons.bubble,
                  color: color2,
                  size: 22,
                ),
                title: Text(
                  'Contact us',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                onTap: () {
                  pushNewScreen(
                    context,
                    screen: ContactUsScreen(),
                    platformSpecific:
                        false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                    withNavBar: true, // OPTIONAL VALUE. True by default.
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  SimpleLineIcons.info,
                  color: color2,
                  size: 22,
                ),
                title: Text(
                  'App info',
                  style: TextStyle(color: color1, fontSize: 20),
                ),
                onTap: () {
                  pushNewScreen(
                    context,
                    screen: AppInfo(),
                    platformSpecific:
                        false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                  );
                },
              ),
              Divider(),
            ],
          ),
        ));
  }

  Link({Text child, String url, onError}) {}
}
