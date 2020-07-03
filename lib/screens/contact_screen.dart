import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/size_config.dart';

import 'login_screen.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29");
  String comment, comment1, comment2, comment3;
  bool showSpinner = false;
  bool isProblemSent = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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

  void addUserComplaints() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        showSpinner = true;
      });
      comment = comment1;
      Firestore.instance
          .collection('users_complaints')
          .document(user.uid)
          .setData({
        'uid': user.uid,
        // 'email': email,
        'comment': comment
      }).whenComplete(() {
        setState(() {
          showSpinner = false;
          isProblemSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(child: Text('CONTACT US')),
            backgroundColor: color1,
          ),
          body: status
              ? Container(
                  child: !isProblemSent
                      ? Column(
                          children: <Widget>[
                            Container(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 32),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Describe your problem here',
                                          style: TextStyle(
                                              fontSize: 18.0, color: color1),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              height: 250,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    child: TextFormField(
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                      validator:
                                                          (String value) {
                                                        if (value.isEmpty ||
                                                            value.length < 20) {
                                                          return 'Describe your problem further';
                                                        }
                                                      },
                                                      onSaved: (input) =>
                                                          comment1 = input,
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    maxLines: null,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    validator:
                                                        (String value) {},
                                                    onSaved: (input) =>
                                                        comment3 = input,
                                                  ),
                                                  TextFormField(
                                                    maxLines: null,
                                                    onSaved: (input) =>
                                                        comment3 = input,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16.0),
                                                    child: RaisedButton(
                                                        color: color2,
                                                        child: Text(
                                                          'Submit',
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () {
                                                          addUserComplaints();
                                                        }),
                                                  ),
                                                ],
                                              )),

/*Card(
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: color1, width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                    width: double.infinity,
                                                    height: 150.0,
                                                    child: Column(
                                                      children: <Widget>[
                                                        TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          maxLines: 5,
                                                          maxLength: 300,
                                                          validator:
                                                              (String value) {
                                                            if (value.isEmpty ||
                                                                value.length <
                                                                    20) {
                                                              return 'Describe your problem further';
                                                            }
                                                          },
                                                          onSaved: (input) =>
                                                              comment = input,
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),*/
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Center(
                                  
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Text("Have you read our FAQS yet?",
                                          style: TextStyle(
                                              fontSize: 14.0, color: color2),
                                          textAlign: TextAlign.center),
                                    ),
                                 
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Center(
                                child: Text(
                                  '''Your complaint is sent successfuly and 
 we will look into your complaint 
 and get back to you shortly.''',
    
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        )))
              : Container(
                  child: Center(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          pushNewScreen(
                            context,
                            screen: LoginScreen(),
                            platformSpecific:
                                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                            withNavBar:
                                false, // OPTIONAL VALUE. True by default.
                          );
                        },
                        child: Text(
                          'Sign in to add a complaint',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}
