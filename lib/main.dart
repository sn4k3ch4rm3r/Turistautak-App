import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/mapview.dart';
import 'package:turistautak/pages/select_route.dart';
import 'package:turistautak/utils/database_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static Directory baseDirectory;

  @override
  Widget build(BuildContext context) {
    getBaseDirectory();
    return FutureBuilder(
      future: getOpenRoute(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData || snapshot.hasError) {
          RouteModel route = snapshot.data != 'none' ? snapshot.data : null; 

          return MaterialApp(
            title: 'Túristautak',
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: MapView(route: route),
            routes: {
              '/map': (context) => MapView(),
              '/select_route': (context) => SelectRoute(),
            },
          );
        }
        return Center(
          child: CircularProgressIndicator()
        );
      },
    );
    
  }

  Future<dynamic> getOpenRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String routeName = prefs.getString('CurrentRoute');
    if(routeName == null)
      return 'none';
    return DatabaseProvider.db.getRoute(routeName);
  }

  Future<void> getBaseDirectory() async {
    baseDirectory = await getApplicationDocumentsDirectory();
  }
}
