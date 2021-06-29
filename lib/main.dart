import 'package:flutter/material.dart';
import 'package:turistautak/pages/mapview.dart';
import 'package:turistautak/pages/select_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MapView(),
      initialRoute: '/map',
      routes: {
        '/map': (context) => MapView(),
        '/select_route': (context) => SelectRoute(),
      },
    );
  }
}