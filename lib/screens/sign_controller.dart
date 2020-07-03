import 'package:flutter/material.dart';
import 'package:pin_point/screens/email_login.dart';
import 'package:pin_point/screens/register.dart';
import 'package:pin_point/style/hexa_color.dart';

class SignInController extends StatefulWidget {
    final bool isOfline;

  const SignInController({Key key, this.isOfline}) : super(key: key);

  @override
  _SignInControllerState createState() => _SignInControllerState();
}

class _SignInControllerState extends State<SignInController>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    //bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double diviceWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      backgroundColor: color1,
      body: SafeArea(
        bottom: false,
        top: false,
        left: false,
        right: false,
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 24),
              Container(
                  child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 64),
                      tabs: <Widget>[
                    Tab(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('SIGN IN'),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('SIGN UP'),
                        ),
                      ),
                    ),
                  ])),
              Expanded(
                  child: Container(
                child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[EmailLogin(isOfline: widget.isOfline,),
                     RegisterScreen(isOfline: widget.isOfline)]),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
