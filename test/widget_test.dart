// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
testWidgets('2nd try This test should pass but fails', (tester) async {

Future future;
await tester.runAsync(() async {
  await tester.pumpWidget(
    MaterialApp(
      home: Row(
        children: <Widget>[
          FlatButton(
            child: const Text('GO'),
            onPressed: () {
              future = Future.error(42);
            },
          ),
          FutureBuilder(
            future: future,
            builder: (_, snapshot) {
              return Container();
            },
          ),
        ],
      ),
    ),
  );

  Future.delayed(Duration.zero, () {tester.tap(find.text('GO'));});
});
});



}
