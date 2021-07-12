import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/components/map.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/route_details.dart';
import 'package:turistautak/utils/map_downloader.dart';

class MapView extends StatefulWidget {

  final RouteModel route;

  const MapView({this.route});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool isFocused = false;
  LatLngBounds selectionBounds;

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

    List<Widget> actions = [];
    if(widget.route == null) {
      actions = [
        IconButton(
          icon: Icon(
            Icons.timeline,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/select_route');
          },
        ),
        IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            if(selectionBounds != null) {
              MyMapDownloader.downloadRegion(selectionBounds, [MyMap.openTopoMapOptions, MyMap.markedTrailsOptions], context: context);
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jelölj ki területet a letöltéshez!'),));
            }
          },
        ),
      ];
    }
    else {
      actions = [
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RouteDetails(route: widget.route)));
          },
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('CurrentRoute');
            Navigator.pushReplacementNamed(context, '/map');
          },
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.route == null ? 'Térkép' : widget.route.name,
          maxLines: 2,
        ),
        actions: actions,
      ),
      body: Container(
        child: MyMap(
          centerOnLocationUpdate: isFocused ? CenterOnLocationUpdate.always : widget.route == null ? CenterOnLocationUpdate.first : CenterOnLocationUpdate.never,
          centerCurrentLocationStreamController: centerCurrentLocationStreamController,
          onLostFocus: () {
            setState(() {
              isFocused = false;
            });
          },
          onRegionSelected: (value) {
            setState(() {
              selectionBounds = value;
            });
          },
          points: widget.route != null ? widget.route.getPoints() : [],
          bounds: widget.route?.getBounds(0.1),
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