import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_point/screens/home_screen.dart';
import 'package:pin_point/style/hexa_color.dart';
enum AppState {//i want to determine which screen to show
  normal,
  search,
  afterSearch,
}
class PlaceDelegate extends SearchDelegate<String> {
  final List<String> placesList;
  double searchLatitude;
 double searchLongitude;
 bool searchActive;
 Color color1 = HexColor("#333132");//deep gray
      Color color2  = HexColor("#F15A29"); //orange
  PlaceDelegate(this.placesList);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final sugesstionList = query.isEmpty
        ? placesList
        : placesList.where((p) => p.toLowerCase().startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            ListTile(
              onTap: ()async {
                searchActive = false;
                Firestore.instance
        .collection("places")
        .where("name", isEqualTo: sugesstionList[index])
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              searchLatitude = doc["coordinate"].latitude;
              searchLongitude = doc["coordinate"].longitude;}));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      searchName: sugesstionList[index],
                      searchLatitude: searchLatitude,
                      searchLongitude: searchLongitude,
                      searchActive: true,
                      
                    ),
                  ),
                );
              },
              title: RichText(
                text: TextSpan(
                    text: sugesstionList[index].substring(0, query.length),
                    style: TextStyle(
                      color: color1,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                          text: sugesstionList[index].substring(query.length),
                          style: TextStyle(color: Colors.grey)),
                    ]),
              ),
            ),
            Divider()
          ],
        );
      },
      itemCount: sugesstionList.length,
    );
  }
}
