import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:turistautak/components/map.dart';

class MapView extends StatefulWidget {

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool isFocused = false;

  StreamController<double> centerCurrentLocationStreamController;
  
  @override
  void initState() {
    centerCurrentLocationStreamController = StreamController<double>();
    super.initState();
  }

  @override
  void dispose() {
    centerCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Térkép'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.timeline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/select_route');
            },
          ),
        ],
      ),
      body: Container(
        child: MyMap(
          centerOnLocationUpdate: isFocused ? CenterOnLocationUpdate.always : CenterOnLocationUpdate.first,
          centerCurrentLocationStreamController: centerCurrentLocationStreamController,
          lostFocus: () {
            setState(() {
              isFocused = false;
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isFocused ? Icons.my_location : Icons.location_searching),
        onPressed: () {
          setState(() {
            isFocused = true;
          });
          centerCurrentLocationStreamController.add(14);
        },
      ),
    );
  }
}