import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/screens/place_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class PlacesList extends StatefulWidget {
  @override
  _PlacesListState createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  String placeName;
  //DocumentReference documentReference = Firestore.instance.collection('places').document().path;

  @override
  Widget build(BuildContext context) {
    Color unselectedColor = HexColor("#1e1e1e");//deep gray
    Color selectedColor = HexColor("#F15A29"); //orange

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
                  return CircularProgressIndicator();
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
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
                        selectedColor = Colors.red;
                        capictyPercentage = 100;
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(48.0),
                                      topRight: const Radius.circular(48.0),
                                      bottomLeft: const Radius.circular(48.0),
                                      bottomRight: const Radius.circular(48.0),
                                    )),
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
                                                  left: 8),
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
                                          child: Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 250,
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
                                            ],
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
      floatingActionButton: FloatingActionButton(
          child: FaIcon(
            FontAwesomeIcons.map,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                      searchActive: false,
                    )));
          }),
    );
  }
}
