import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:path/path.dart';
import 'package:pin_point/utilities/size_config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color color1 = HexColor("#1e1e1e"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  String updatedName;
  String phone;
  AppState state;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  FirebaseUser user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    state = AppState.free;

    checkUser();

    super.initState();
  }

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

  Future uploadPic(BuildContext context) async {
    String fileName = basename(_image.path);
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    String uri = await taskSnapshot.ref.getDownloadURL();

    Firestore.instance.collection('users').document(user.uid).updateData({
      'profileImage': uri,
    });
    print(uri);
    setState(() {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Profile picture updated!'),
      ));
    });
  }

  Widget _buildFirstNameFormText() {
    return Form(
      key: _formKey,
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: KTextFieldDecoration.copyWith(hintText: 'Your name'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter your name';
          }
        },
        onSaved: (input) => updatedName = input,
      ),
    );
  }

  Widget _buildPhoneFormText() {
    return Form(
      key: _formKey1,
      child: TextFormField(
        keyboardType: TextInputType.phone,
        decoration:
            KTextFieldDecoration.copyWith(hintText: 'Enter your phone number'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter your phone number!';
          }
        },
        onSaved: (input) => phone = input,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    Future<Widget> getImage(BuildContext context) async {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: color2,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Ionicons.md_photos,
                ),
                onPressed: () async {
                  var image =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _image = image;
                    state = AppState.picked;
                  });
                  if (image != null) {
                    if (state == AppState.picked) _cropImage(context);
                  }
                }),
            IconButton(
                icon: Icon(
                  Icons.camera_alt,
                ),
                onPressed: () async {
                  var image =
                      await ImagePicker.pickImage(source: ImageSource.camera);

                  setState(() {
                    state = AppState.picked;

                    _image = image;
                  });
                  if (image != null) {
                    if (state == AppState.picked) _cropImage(context);
                  }
                }),
          ],
        ),
      ));
    }

    Future<Widget> updateName(BuildContext context) async {
      return showDialog<AlertDialog>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                actionsPadding: EdgeInsets.only(bottom: 16),
                contentPadding: EdgeInsets.only(top: 32),
                content: Container(
                  width: SizeConfig.screenWidth - 64,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      height: 70,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "UPDATE USER NAME",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: color2,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            Container(
                                height: 70,
                                child: SingleChildScrollView(
                                  child: Column(children: <Widget>[
                                    new TextFormField(
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Invalid name !';
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: KTextFieldDecoration.copyWith(
                                          hintText: 'User Name'),
                                      onSaved: (input) => updatedName = input,
                                    ),
                                ]),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                        icon: Icon(
                          Icons.check,
                          color: color2,
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            try {
                                  _updateUserName(updatedName);
                                 // Navigator.of(context).pop();
                              Navigator.pop(context);
                            } catch (e) {}
                          }
                        }),
                  ),
                  SizedBox(
                    width: 130,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: status ? color2 : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ]);
          });
 }

    Future<Widget> updatePhoneNumber(BuildContext context) async {
          return showDialog<AlertDialog>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                actionsPadding: EdgeInsets.only(bottom: 16),
                contentPadding: EdgeInsets.only(top: 32),
                content: Container(
                  width: SizeConfig.screenWidth - 64,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      height: 60,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "UPDATE PHONE NUMBER",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: color2,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            Container(
                                height: 70,
                                child: SingleChildScrollView(
                                  child: Column(children: <Widget>[
                                    new TextFormField(
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Invalid phone number!';
                                        }
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: KTextFieldDecoration.copyWith(
                                          hintText: 'Phone Number'),
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
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                        icon: Icon(
                          Icons.check,
                          color: color2,
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            try {
                                  _updateUserPhone(phone);
                                
                              Navigator.pop(context);
                            } catch (e) {}
                          }
                        }),
                  ),
                  SizedBox(
                    width: 130,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: status ? color2 : Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                ]);
          }
                );
   }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text('UPDATE ACCOUNT')),
          backgroundColor: color1,
        ),
        body: status
            ? Builder(
                builder: (BuildContext context) => Container(
                      child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return CircularProgressIndicator();

                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            } else {
                              final list = snapshot.data;
                              return Column(
                                children: <Widget>[
                                  Container(
                                    height: 2 * SizeConfig.screenHeight / 10,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, bottom: 8),
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 55,
                                            foregroundColor: color1,
                                            child: ClipOval(
                                              child: SizedBox(
                                                width: 110,
                                                height: 110,
                                                child: (_image != null)
                                                    ? Image.file(_image,
                                                        fit: BoxFit.fill)
                                                    : (snapshot.data[
                                                                'profileImage'] !=
                                                            null)
                                                        ? Image.network(
                                                            snapshot.data[
                                                                'profileImage'],
                                                            fit: BoxFit.fill)
                                                        : Image.asset(
                                                            'images/user.png',
                                                            fit: BoxFit.fill),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              icon: Icon(
                                                Icons.camera_alt,
                                                size: 36,
                                                color: color2,
                                              ),
                                              onPressed: () {
                                                if (state == AppState.free)
                                                  getImage(context);
                                              })
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 7 *
                                          MediaQuery.of(context).size.height /
                                          12,
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Icon(
                                              Icons.person_pin,
                                              size: 32,
                                              color: color2,
                                            ),
                                            title: Text(
                                              "User Name",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: color1),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot
                                                          .data['firstName'],
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      list['lastName'],
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onTap: () => updateName(context),
                                            trailing: IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {}),
                                          ),
                                          Divider(),
                                          ListTile(
                                              onTap: () =>
                                                  updatePhoneNumber(context),
                                              leading: Icon(
                                                Icons.phone_android,
                                                color: color2,
                                              ),
                                              title: Text(
                                                "Phone Number",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: color1),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  list['phone'],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              trailing: IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {})),
                                          Divider(),
                                          ListTile(
                                            leading: Icon(
                                              Icons.email,
                                              color: color2,
                                            ),
                                            title: Text(
                                              "Email",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: color1),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                list['email'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                          Divider(),
                                          ListTile(
                                            leading: Icon(
                                              AntDesign.gift,
                                              color: color2,
                                              size: 24,
                                            ),
                                            title: Text(
                                              "You have reward",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: color1),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                list['points'].toString() +
                                                    " points",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }),
                    ))
            : Container());
  }

  Future<Null> _cropImage(BuildContext context) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: color2,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
      if (state == AppState.cropped) uploadPic(context);
    }
  }

  void _clearImage() {
    _image = null;
    setState(() {
      state = AppState.free;
    });
  }

  _updateUserName(String name) {
    Firestore.instance.collection('users').document(user.uid).updateData({
      'firstName': name,
    });
    Firestore.instance.collection('users').document(user.uid).updateData({
      'lastName': '',
    });
  }

  _updateUserPhone(String phone) {
    Firestore.instance.collection('users').document(user.uid).updateData({
      'phone': phone,
    });
  }
}
