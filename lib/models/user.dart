import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String email = '';
  String firstName = '';
  String lastName = '';
  Settings settings = Settings(allowPushNotifications: true);
  String phone = '';
  bool active = false;
  Timestamp lastOnlineTimestamp = Timestamp.now();
  String uid;
  String profileImage = '';
  bool selected = false;
  String appIdentifier = 'Flutter ${Platform.operatingSystem}';

  User(
      {this.email,
      this.firstName,
      this.phone,
      this.lastName,
      this.active,
      this.lastOnlineTimestamp,
      this.settings,
      this.uid,
      this.profileImage});

  String fullName() {
    return '$firstName $lastName';
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
        email: parsedJson['email'] ?? "",
        firstName: parsedJson['firstName'] ?? '',
        lastName: parsedJson['lastName'] ?? '',
        active: parsedJson['active'] ?? false,
        lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
        settings: Settings.fromJson(
            parsedJson['settings'] ?? {'allowPushNotifications': true}),
        phone: parsedJson['phone'] ?? "",
        uid: parsedJson['uid'] ?? parsedJson['uid'] ?? '',
        profileImage: parsedJson['profileImage'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "email": this.email,
      "firstName": this.firstName,
      "lastName": this.lastName,
      //"settings": this.settings.toJson(),
      "phone": this.phone,
      "uid": this.uid,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      "profileImage": this.profileImage,
      'appIdentifier': this.appIdentifier
    };
  }
}

class Settings {
  bool allowPushNotifications = true;

  Settings({this.allowPushNotifications});

  factory Settings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Settings(
        allowPushNotifications: parsedJson['allowPushNotifications'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'allowPushNotifications': this.allowPushNotifications};
  }
}