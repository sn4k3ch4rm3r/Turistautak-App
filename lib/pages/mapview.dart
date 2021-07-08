import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/components/map.dart';
import 'package:turistautak/models/route.dart';

class MapView extends StatefulWidget {

  final RouteModel route;

  const MapView({this.route});

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
        title: Text(
          widget.route == null ? 'Térkép' : widget.route.name
        ),
        actions: [
          if(widget.route == null) 
            IconButton(
              icon: Icon(
                Icons.timeline,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/select_route');
              },
            ),
          if(widget.route != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('CurrentRoute', '');
                Navigator.pushReplacementNamed(context, '/map');
              },
            )
        ],
      ),
      body: Container(
        child: MyMap(
          centerOnLocationUpdate: isFocused ? CenterOnLocationUpdate.always : widget.route == null ? CenterOnLocationUpdate.first : CenterOnLocationUpdate.never,
          centerCurrentLocationStreamController: centerCurrentLocationStreamController,
          lostFocus: () {
            setState(() {
              isFocused = false;
            });
          },
          points: widget.route != null ? widget.route.getPoints() : [],
          bounds: widget.route != null ? widget.route.getBounds(0.1) : null,
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