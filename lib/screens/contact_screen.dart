import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_point/style/hexa_color.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Color color1 = HexColor("#333132"); //deep gray
  Color color2 = HexColor("#F15A29");
  String comment;
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Contact US'),
            backgroundColor: color1,
          ),
          body: status
              ? Container(
                  child: !isProblemSent
                      ? Container(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Describe your problem here',
                                      style: TextStyle(
                                          fontSize: 18.0, color: color1),
                                    ),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 250.0,
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          validator: (String value) {
                                            if (value.isEmpty ||
                                                value.length < 20) {
                                              return 'Describe your problem further';
                                            }
                                          },
                                          onSaved: (input) => comment = input,
                                        )),
                                    RaisedButton(
                                        color: color2,
                                        child: Text(
                                          'Submit',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          addUserComplaints();
                                        }),
                                    SizedBox(height: 16.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                              "Have you read our FAQS yet?",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: color2),
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                
                                'Your complaint is sent successfuly and we will look into your complaint and get back to you shortly ',
                                style: TextStyle( fontSize: 20,color: color2),
                              ),
                            ),
                          ),
                        )))
              : Container(
                  child: Center(
                    child: Text(
                      'Sign in to add a complaint',
                      style: TextStyle(fontSize: 18.0, color: color2),
                    ),
                  ),
                )),
    );
  }
}
