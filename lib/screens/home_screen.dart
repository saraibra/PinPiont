import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';
import 'package:pin_point/screens/places_list.dart';
import 'package:pin_point/search/place_delegate.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/drawer.dart';

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

    
   String _platformVersion = 'Unknown';

  MapboxNavigation _directions;

  bool _arrived = false;
  double _distanceRemaining, _durationRemaining;
  AppState state;

  List<String> placesList = [];
  bool searchActive = false;

 Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
        int selectedIndex = 0;

  Position _currentPosition;
  FirebaseUser user;
  dynamic data1;

  double latitude = 25.2193;
  double longitude = 55.2738;
  var point = <LatLng>[];
  List<Marker> allMarkers = [];
  List<Marker> searchMarker = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool status = false;
  bool val = true;
  bool notificationTime = true;
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
            notificationTime = datasnapshot.data['notificationTime'];
          }
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
        new Marker(
          width: 80.0,
          height: 80.0,
          point: new LatLng(latitude, longitude),
          builder: (ctx) => new Container(
            child: new IconButton(
              icon: FaIcon(
                FontAwesomeIcons.home,
                color: Colors.redAccent,
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
    Color color2 = HexColor("#f05a2b");
    Color color1 = HexColor("#223469");

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
              new Marker(
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
                            return Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: 80,
                                    color: color1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Text(
                                              snapshot.data.documents[i]
                                                  ['name'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24),
                                            ),
                                            Text(
                                                snapshot.data.documents[i]
                                                    ['type'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: ListTile(
                                      leading: FaIcon(
                                        FontAwesomeIcons.mapMarker,
                                        color: color2,
                                        size: 24,
                                      ),
                                      title: Text(snapshot.data.documents[i]
                                          ['address']),
                                    ),
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
  void initState() {
    state = AppState.normal;

    super.initState();
    getUserDoc();
    getData();
     initializing();
checkUser() ;
      showNotifications();
    if (widget.searchActive != null) {
      if (widget.searchActive) {
        state = AppState.afterSearch;

        print(widget.searchLatitude);

        //  navigateToSearchPlace();

      }
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
              color: Colors.redAccent,
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
              color: Colors.redAccent,
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
     final _origin =
      Location(name: "Home", latitude: 25.2193, longitude: 55.2738);
final _destination = Location(
      name:widget.searchName, latitude: widget.searchLatitude, longitude:  widget.searchLongitude);

    return (state == AppState.afterSearch)
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop()),
              title: Text(widget.searchName),
              backgroundColor: color1,
            ),
            body:
             navigateToSearchPlace(widget.searchName),
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
                    simulateRoute: true, language: "English", units: VoiceUnits.metric);
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
            body: laodMapMarkers(context),
            floatingActionButton: FloatingActionButton(
                child: FaIcon(
                  FontAwesomeIcons.list,
                  color: Colors.white,
                ),
                onPressed: () {
          pushNewScreen(
        context,
        screen: PlacesList(),
        platformSpecific: false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
        withNavBar: true, // OPTIONAL VALUE. True by default.
    );
                 // Navigator.pushReplacementNamed(context, 'placesList');
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
      if (arrived)
        {
          await Future.delayed(Duration(seconds: 3));
          await _directions.finishNavigation();
        }
    });

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions.platformVersion;
    } 
    
     catch(e) {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }
void initializing() async {
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void showNotifications() async {
    await notification();
  }
    Future selectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
    
  }

  Future<void> notification() async {
    var time = Time(15, 22, 0);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_ID',
      'channel title',
      'channel body',
      priority: Priority.High,
      importance: Importance.Max,
      ticker: 'PinPoint',
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0, "PinPoint","You have a new notification ",time,notificationDetails);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(child: Text('Ok'),
        isDefaultAction: true,
        onPressed: (){
          print("notification pressed");
        },
        )
      ],
    );
  }

 
}
