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
  final List<LatLng> points;
  final LatLng hoverPoint;
  final LatLngBounds bounds;
  // ignore: avoid_init_to_null
  MyMap({Key key, this.centerOnLocationUpdate = CenterOnLocationUpdate.never, this.lostFocus = null, this.centerCurrentLocationStreamController = null, this.points = const <LatLng>[], this.hoverPoint = null, this.bounds = null}) : super(key: key);

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
    if(widget.hoverPoint != null && widget.hoverPoint is LatLng) {
      _markers = [Marker(
        point: widget.hoverPoint,
        width: 8,
        height: 8,
        builder: (BuildContext context) => Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )];
    }
    var mapLayers = [
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
      PolylineLayerOptions(
        polylines: [
          Polyline(
            points: widget.points,
            color: Color.fromARGB(230, 50, 100, 255),
            strokeWidth: 3.0,
          )
        ]
      ),
      MarkerLayerOptions(markers: _markers),
    ];
    if(widget.centerCurrentLocationStreamController != null) {
      mapLayers.add(LocationMarkerLayerOptions());
    }

    return FlutterMap(
      options: MapOptions(
        center: LatLng(47, 19.5),
        bounds: widget.bounds,
        zoom: 10,
        minZoom: 1,
        maxZoom: 17,
        interactiveFlags: InteractiveFlag.all -InteractiveFlag.rotate,
        plugins: widget.centerCurrentLocationStreamController == null?[]:[
          LocationMarkerPlugin(
            centerCurrentLocationStream: widget.centerCurrentLocationStreamController.stream,
            centerOnLocationUpdate: widget.centerOnLocationUpdate,
            centerAnimationDuration: Duration(milliseconds: 300),
          ),
        ],
        onTap: (point) {
        },
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if(hasGesture && widget.lostFocus != null) {
            widget.lostFocus();
          }
        }
      ),
      layers: mapLayers,
      mapController: _mapController,
    );
  }
}