import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_point/screens/image_edit.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/drawer.dart';
import 'package:path/path.dart';

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
  Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
  String updatedName;
  AppState state;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    Future<Widget> getImage(BuildContext context) async {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: color2,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  FontAwesomeIcons.images,
                ),
                onPressed: () async {
                  var image =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _image = image;
                    state = AppState.picked;
                  });

                  if (state == AppState.picked) _cropImage(context);
                }),
            IconButton(
                icon: Icon(FontAwesomeIcons.camera),
                onPressed: () async {
                  var image =
                      await ImagePicker.pickImage(source: ImageSource.camera);

                  setState(() {
                    state = AppState.picked;

                    _image = image;
                  });
                  if (state == AppState.picked) _cropImage(context);
                }),
          ],
        ),
      ));
    }

    Future<Widget> updateName(BuildContext context) async {
      return showModalBottomSheet(
            isScrollControlled: true,

          context: context,
          builder: (builder) {
            return new AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
              child: new Container(
                height: 200,
              alignment: Alignment.bottomCenter,
                //could change this to Color(0xFF737373),
                //so you don't have to change MaterialApp canvasColor
               
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(10.0),
                            topRight: const Radius.circular(10.0))),
                    child: new Center(
        
                        child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
 
                          children: <Widget>[
                            Text('Update user name'),
                            
                              _buildFirstNameFormText(),
                           
                         Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          _formKey.currentState.save();
                                          _updateUserName(updatedName);
                                        }
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () =>
                                          Navigator.of(context).pop())
                                ],
                              ),
                        
                          ],
                        ),
                      
                    )
                    //),
              ),
            );
          });
    }

    return Scaffold(
              resizeToAvoidBottomPadding: false,

        appBar: AppBar(
          leading: IconButton(
              icon: Icon(FontAwesomeIcons.arrowLeft),
              onPressed: () {
                Navigator.canPop(context);
              }),
          title: Text('Update account'),
          backgroundColor: color1,
        ),
        drawer: PinpointDrawer(),
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
                              return SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 16),
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 70,
                                            foregroundColor: color1,
                                            child: ClipOval(
                                              child: SizedBox(
                                                width: 120,
                                                height: 120,
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
                                                Icons.camera_enhance,
                                                size: 32,
                                                color: color2,
                                              ),
                                              onPressed: () {
                                                if (state == AppState.free)
                                                  getImage(context);
                                              })
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(
                                                Icons.person_pin,
                                                size: 32,
                                                color: color1,
                                              ),
                                              title: Text(
                                                "User name",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: color1),
                                              ),
                                              subtitle: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot
                                                          .data['firstName'],
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      list['lastName'],
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () => updateName(context),
                                              trailing: IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {}),
                                            ),
                                            Divider(),
                                            ListTile(
                                                leading: Icon(
                                                  Icons.phone_android,
                                                  color: color1,
                                                ),
                                                title: Text(
                                                  "Phone number",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: color1),
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    list['phone'],
                                                    style: TextStyle(
                                                        fontSize: 18,
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
                                                  color: color1,
                                                ),
                                                title: Text(
                                                  "Email",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: color1),
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    list['email'],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () {})),
                                            Divider(),
                                            ListTile(
                                              leading: FaIcon(
                                                FontAwesomeIcons.award,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  list['points'].toString() +
                                                      " points",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
            toolbarColor: Colors.deepOrange,
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
  }
}
