import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class MyMap extends StatefulWidget {
  final CenterOnLocationUpdate centerOnLocationUpdate;
  final StreamController<double> centerCurrentLocationStreamController;
  final lostFocus;
  MyMap({Key key, this.centerOnLocationUpdate, this.lostFocus, this.centerCurrentLocationStreamController}) : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {


  MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    Permission.location.request();
    super.initState();
  }
 

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(47, 19.5),
        zoom: 10,
        minZoom: 1,
        maxZoom: 17,
        interactiveFlags: InteractiveFlag.all -InteractiveFlag.rotate,
        plugins: [
          LocationMarkerPlugin(
            centerCurrentLocationStream: widget.centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: widget.centerOnLocationUpdate,
            centerAnimationDuration: Duration(milliseconds: 300),
          ),
        ],
        onTap: (point) {
        },
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if(hasGesture) {
            widget.lostFocus();
          }
        }
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
          subdomains: ["a", "b", "c"],
          tileFadeInDuration: 300,
        ),
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.hu/tt/{z}/{x}/{y}.png",
          backgroundColor: Colors.transparent,
          subdomains: ["a", "b", "c"],
          fastReplace: true,
          tileFadeInDuration: 300,
        ),
        MarkerLayerOptions(markers: _markers),
        LocationMarkerLayerOptions(),
      ],
      mapController: _mapController,
    );
  }
}