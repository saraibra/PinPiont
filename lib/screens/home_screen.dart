import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/places_list.dart';
import 'package:pin_point/screens/waiting_list.dart';
import 'package:pin_point/search/place_delegate.dart';
import 'package:pin_point/style/constants.dart';
import 'package:pin_point/style/hexa_color.dart';

class HomeScreen extends StatefulWidget {
  final String searchName;
  final double searchLongitude;
  final double searchLatitude;
  final bool searchActive;
  const HomeScreen(
      {Key key,
      this.searchName,
      this.searchLongitude,
      this.searchLatitude,
      this.searchActive})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum AppState {
  //i want to determine which screen to show
  normal,
  search,
  afterSearch,
}

class _HomeScreenState extends State<HomeScreen> {
// for internet connection
  BuildContext ctx;
  bool canProceed = true;

  bool isOffline = false;
  bool dialogIsVisible = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  //

  String _platformVersion = 'Unknown';

  MapboxNavigation _directions;

  bool _arrived = false;
  double _distanceRemaining, _durationRemaining;
  AppState state;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;
  List<String> placesList = [];
  bool searchActive = false;

  Color color1 = HexColor("#333132"); //deep gray
  Color color2 = HexColor("#F15A29"); //orange
  int selectedIndex = 0;

  Position _currentPosition;
  FirebaseUser user;
  dynamic data1;

  double latitude;
  double longitude;
  var point = <LatLng>[];
  List<Marker> allMarkers = [];
  List<Marker> searchMarker = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;
  bool exist = false;

  bool val = true;
  bool notificationTime = true;
  var finTime;
  var finTimeSeconds;
  int notificationMin, notificationMin2;
  Future<void> checkUser() async {
    user = await _auth.currentUser();

    if (user != null) {
      final snapShot = await Firestore.instance
          .collection('user_places')
          .document(user.uid)
          .get();
      if (snapShot.exists) {
        DocumentReference documentReference =
            Firestore.instance.collection("user_places").document(user.uid);
        documentReference.get().then((datasnapshot) {
          if (datasnapshot.exists) {
            val = datasnapshot.data['allowNotifications'];
            notificationTime = datasnapshot.data['NotificationTime'];
            finTime = datasnapshot.data['finTime'].toDate();
            final DateTime timeNow = DateTime.now();
            var nowTimeSeconds = timeNow.toUtc().millisecondsSinceEpoch;
            var finTimeSeconds = finTime.toUtc().millisecondsSinceEpoch;
            if (finTimeSeconds > nowTimeSeconds) {
              notificationMin = finTime.difference(timeNow).inMinutes;
              if (notificationTime) {
                print(notificationMin.toString());
                showNotification(notificationMin);
              } else {
                notificationMin2 = notificationMin - 15;
                print(notificationMin2.toString());
                showNotification(notificationMin2);
              }
            }
          }
        });
        setState(() {
          exist = true;

          //print(exist.toString());
        });
      }
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

  setMarkers() {
    return allMarkers;
  }

  addToMarkerList() async {
    setState(() {
      allMarkers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: new LatLng(latitude, longitude),
          builder: (ctx) => new Container(
            child: new IconButton(
              icon: FaIcon(
                FontAwesomeIcons.home,
                color: color1,
                size: 36,
              ),
              onPressed: () {},
            ),
          ),
        ),
      );
    });
  }

  Future<DocumentReference> getUserDoc() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final Firestore _firestore = Firestore.instance;
    user = await _auth.currentUser();

    //DocumentReference ref = _firestore.collection('users').document(user.uid);
    //return ref;
  }

  Future _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      _currentPosition = position;
      setState(() {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;

        Firestore.instance.collection('users').document(user.uid).updateData({
          'location': GeoPoint(latitude, longitude),
        });
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget laodMapMarkers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("places").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            if (snapshot.data.documents[i]['coordinate'].latitude == latitude &&
                snapshot.data.documents[i]['coordinate'].longitude ==
                    longitude) {
              var ref = Firestore.instance
                  .collection("places")
                  .where("id", isEqualTo: i)
                  .getDocuments();

              String time =
                  new DateTime.now().millisecondsSinceEpoch.toString();
              Firestore.instance
                  .collection('places')
                  .document(snapshot.data.documents[i].documentID)
                  .collection('placeDts')
                  .document(i.toString())
                  .setData({
                'timeStamp': time,
                'totalCustomerCount': 1,
                'remainingCustomerCount': 1,
                'placeId': i,
              });
            }
            allMarkers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: new LatLng(
                    snapshot.data.documents[i]['coordinate'].latitude,
                    snapshot.data.documents[i]['coordinate'].longitude),
                builder: (ctx) => new Container(
                  child: new IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.mapMarker,
                      color: color2,
                      size: 36,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          builder: (Builder) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, left: 16),
                              child: Container(
                                color: Colors.white,
                                child: ListView(
                                  children: <Widget>[
                                    Text(
                                      snapshot.data.documents[i]['name'],
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color1,
                                          fontSize: 24),
                                    ),
                                    Text(snapshot.data.documents[i]['type'],
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16)),
                                    Text(
                                      'Open',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    ListTile(
                                      leading: FaIcon(
                                        FontAwesomeIcons.mapMarker,
                                        color: color2,
                                        size: 24,
                                      ),
                                      title: Text(snapshot.data.documents[i]
                                          ['address']),
                                    ),
                                    ListTile(
                                      leading: FaIcon(
                                        FontAwesomeIcons.clock,
                                        color: color2,
                                        size: 24,
                                      ),
                                      title: Row(
                                        children: <Widget>[
                                          Text(snapshot.data.documents[i]
                                              ['fromTime']),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text('to'),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(snapshot.data.documents[i]
                                              ['toTime']),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      leading: FaIcon(
                                        FontAwesomeIcons.phoneAlt,
                                        color: color2,
                                        size: 24,
                                      ),
                                      title: Text(snapshot.data.documents[i]
                                          ['phoneNumber']),
                                    ),
                                    ListTile(
                                      leading: FaIcon(
                                        FontAwesomeIcons.peopleArrows,
                                        color: color2,
                                        size: 24,
                                      ),
                                      title: Text(snapshot.data
                                              .documents[i]['customerNumbers']
                                              .toString() +
                                          "/" +
                                          snapshot.data.documents[i]['capcity']
                                              .toString()),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          context: context);
                    },
                  ),
                ),
              ),
            );
          }
          return latitude == null || longitude == null
              ? Container(child: Center(child: CircularProgressIndicator()))
              : getMap(latitude, longitude, 12.0, allMarkers);
        });
  }

  Widget getMap(
      double latitude, double longitude, double zoom, List<Marker> allMarker) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(latitude, longitude),
        zoom: zoom,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken':
                'pk.eyJ1Ijoic2FyYS1pYnJhaGltIiwiYSI6ImNrOWVwZjVudTAzd3IzaG11Yml3djNvdnEifQ.-n5W4gLe4uVwQTB3j7ayCQ',
            'id': 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(
          markers: allMarker,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() {
          isOffline = false;
          dialogIsVisible = false;
        });
        break;
      case ConnectivityResult.mobile:
        setState(() {
          isOffline = false;
          dialogIsVisible = false;
        });
        break;
      case ConnectivityResult.none:
        setState(() => isOffline = true);
        buildAlertDialog("Internet connection cannot be establised!");
        break;
      default:
        setState(() => isOffline = true);
        break;
    }
  }

  void buildAlertDialog(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
          if (isOffline && !dialogIsVisible) {
            dialogIsVisible = true;
            canProceed = false;
            showDialog(
                barrierDismissible: canProceed,
                context: ctx,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.0),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.portable_wifi_off,
                          color: color2,
                          size: 36.0,
                        ),
                        !canProceed
                            ? Text(
                                "Check your internet connection before proceeding.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.0),
                              )
                            : Text(
                                "Please! proceed by connecting to a internet connection",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0, color: color2),
                              ),
                      ],
                    ),
                    actions: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                        child: Text(
                          "CLOSE THE APP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (isOffline) {
                            setState(() {
                              canProceed = false;
                            });
                          } else {
                            setState(() {
                              canProceed = true;
                              Navigator.pop(context);
                            });
//Navigator.pop(context);                            //your code
                          }
                        },
                        child: Text(
                          "PROCEED",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                });
          }
        }));
  }

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    state = AppState.normal;

    super.initState();
    if (!isOffline) {
      getUserDoc();
      getData();
      checkUser();
    }

    _getCurrentLocation();
    initializing();

    if (widget.searchActive != null) {
      if (widget.searchActive) {
        state = AppState.afterSearch;

        print(widget.searchLatitude);

        //  navigateToSearchPlace();

      }

      // if (status) {
      //print(val.toString());

      // if (val) {
      // }
      // }
    }
    //_getCurrentLocation();
    // determinewUserPlace();
    initPlatformState();
  }

  Widget navigateToSearchPlace(String placeName) {
    /*  _origin =
      Location(name: " Home", latitude: latitude, longitude: longitude);
   _destination = Location(
      name:placeName , latitude: widget.searchLatitude, longitude:widget.searchLongitude);*/
    searchMarker.add(
      new Marker(
        width: 80.0,
        height: 80.0,
        point: (widget.searchLatitude == null || widget.searchLongitude == null)
            ? Container(child: Center(child: CircularProgressIndicator()))
            : new LatLng(widget.searchLatitude, widget.searchLongitude),
        builder: (ctx) => new Container(
          child: new IconButton(
            icon: FaIcon(
              FontAwesomeIcons.mapMarkedAlt,
              color: color2,
              size: 36,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
    searchMarker.add(
      new Marker(
        width: 80.0,
        height: 80.0,
        point: (latitude == null || longitude == null)
            ? Container(child: Center(child: CircularProgressIndicator()))
            : new LatLng(latitude, longitude),
        builder: (ctx) => new Container(
          child: new IconButton(
            icon: FaIcon(
              FontAwesomeIcons.home,
              color: color2,
              size: 36,
            ),
            onPressed: () {},
          ),
        ),
      ),
    );

    return widget.searchLatitude == null || widget.searchLongitude == null
        ? Container(child: Center(child: CircularProgressIndicator()))
        : getMap(
            widget.searchLatitude, widget.searchLongitude, 16.0, searchMarker);
  }

  getData() async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("places").getDocuments();
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      var a = querySnapshot.documents[i]['name'];
      placesList.add(a);
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    final _origin =
        Location(name: "Home", latitude: latitude, longitude: longitude);
    final _destination = Location(
        name: widget.searchName,
        latitude: widget.searchLatitude,
        longitude: widget.searchLongitude);

    return (state == AppState.afterSearch)
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()),
              title: Text(widget.searchName),
              backgroundColor: color1,
            ),
            body: navigateToSearchPlace(widget.searchName),
            floatingActionButton: FloatingActionButton(
              child: FaIcon(
                FontAwesomeIcons.car,
                color: Colors.white,
              ),
              onPressed: () async {
                print(_origin.toString);
                await _directions.startNavigation(
                    origin: _origin,
                    destination: _destination,
                    mode: NavigationMode.drivingWithTraffic,
                    simulateRoute: true,
                    language: "English",
                    units: VoiceUnits.metric);
              },
            ),
          )
        : Scaffold(
            // drawer: PinpointDrawer(),
            appBar: AppBar(
              title: Text('Home'),
              backgroundColor: color1,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: PlaceDelegate(placesList));
                    })
              ],
            ),
            body: isOffline
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : laodMapMarkers(context),
            floatingActionButton: FloatingActionButton(
                child: FaIcon(
                  FontAwesomeIcons.list,
                  color: Colors.white,
                ),
                onPressed: () {
                  pushNewScreen(
                    context,
                    screen: PlacesList(),
                    platformSpecific:
                        false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                    withNavBar: true, // OPTIONAL VALUE. True by default.
                  );
                }),
          );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapboxNavigation(onRouteProgress: (arrived) async {
      _distanceRemaining = await _directions.distanceRemaining;
      _durationRemaining = await _directions.durationRemaining;

      setState(() {
        _arrived = arrived;
      });
      if (arrived) {
        await Future.delayed(Duration(seconds: 3));
        await _directions.finishNavigation();
      }
    });

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } catch (e) {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void initializing() async {
    initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    showDialog(
        context: context,
        builder: (_) {
          pushNewScreen(
            context,
            screen: WaitingList(),
            platformSpecific:
                false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
            withNavBar: true, // OPTIONAL VALUE. True by default.
          );
        });
  }

  showNotification(int min) async {
    print(finTime.toString());
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(minutes: min));
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'channel_ID', 'channel title', 'channel body',
            //priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test',
            enableVibration: true);
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'PinPoint ',
        'You have a notification',
        scheduledNotificationDateTime,
        notificationDetails);
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
