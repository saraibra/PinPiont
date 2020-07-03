import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/place_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:pin_point/utilities/size_config.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.widget.dart';

class PlacesList extends StatefulWidget {
  @override
  _PlacesListState createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  String placeName;
  //DocumentReference documentReference = Firestore.instance.collection('places').document().path;

  @override
  Widget build(BuildContext context) {
    Color unselectedColor = HexColor("#1e1e1e"); //deep gray
    Color selectedColor = HexColor("#F15A29"); //orange
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
                  automaticallyImplyLeading: false,

        title: Center(child: Text('HOME')),
        backgroundColor: unselectedColor,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("places")
                  .orderBy('id')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final list = snapshot.data.documents;

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      var ref = Firestore.instance
                          .collection("places")
                          .where("id", isEqualTo: index)
                          .getDocuments();
                      int customers = list[index]['customerNumbers'];
                      int capcity = list[index]['capcity'];
                      bool capcityReached = false;
                      double result = customers / capcity;
                      int capictyPercentage = (result * 100).toInt();
                      if (result == 0.3 || result > 0.3) {
                        capcityReached = true;
                        selectedColor = selectedColor;
                        capictyPercentage = 98;
                        ref.then((v) => Firestore.instance
                            .collection('places')
                            .document(v.documents[0].documentID)
                            .updateData({'capcityReached': capcityReached}));
                      } else {
                        selectedColor = HexColor("#F15A29");

                        capcityReached = false;
                        ref.then((v) => Firestore.instance
                            .collection('places')
                            .document(v.documents[0].documentID)
                            .updateData({'capcityReached': capcityReached}));
                      }

                      return Column(
                        children: <Widget>[
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        list[index]['name'],
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    subtitle: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                list[index]['type'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8),
                                              child: Text(
                                                list[index]['customerNumbers']
                                                        .toString() +
                                                    " / " +
                                                    list[index]['capcity']
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: 
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: StepProgressIndicator(
                                                  totalSteps: 100,
                                                  currentStep:
                                                      capictyPercentage,
                                                  size: 8,
                                                  padding: 0,
                                                  selectedColor: selectedColor,
                                                  unselectedColor: Colors.grey,
                                                  roundedEdges:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                           
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      placeName = list[index]['name'];

                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => PlaceScreen(
                                                    title: placeName,
                                                    id: index,
                                                  )));
                                    }),
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  );
                }
              })),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          height: SizeConfig.blockSizeHorizontal * 12,
                width: SizeConfig.blockSizeHorizontal * 12,
          child: FloatingActionButton(
              child: Icon(
                Ionicons.md_map,
                color: Colors.white,
              ),
              onPressed: () {
                pushNewScreen(
                  context,
                  screen: HomeScreen(
                    searchActive: false,
                  ),
                  platformSpecific:
                      false, // OPTIONAL VALUE. False by default, which means the bottom nav bar will persist
                  withNavBar: true, // OPTIONAL VALUE. True by default.
                );
              }),
        ),
      ),
    );
  }
    
}
