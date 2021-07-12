import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:turistautak/utils/caching_tile_provider.dart';
import 'package:turistautak/utils/map_rectangle_selector.dart';

class MyMap extends StatefulWidget {
  final CenterOnLocationUpdate centerOnLocationUpdate;
  final StreamController<double> centerCurrentLocationStreamController;
  final onLostFocus;
  final onRegionSelected;
  final List<LatLng> points;
  final LatLng hoverPoint;
  final LatLngBounds bounds;

  static final  LayerOptions openTopoMapOptions = TileLayerOptions(
    urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
    subdomains: ["a", "b", "c"],
    tileFadeInDuration: 300,
    tileProvider: CachingTileProvider(),
  );
  static final LayerOptions markedTrailsOptions = TileLayerOptions(
    urlTemplate: "https://{s}.tile.openstreetmap.hu/tt/{z}/{x}/{y}.png",
    backgroundColor: Colors.transparent,
    subdomains: ["a", "b", "c"],
    fastReplace: true,
    tileFadeInDuration: 300,
    tileProvider: CachingTileProvider(),
  );

  // ignore: avoid_init_to_null
  MyMap({Key key, this.centerOnLocationUpdate = CenterOnLocationUpdate.never, this.onLostFocus, this.centerCurrentLocationStreamController, this.points = const <LatLng>[], this.hoverPoint, this.bounds, this.onRegionSelected}) : super(key: key);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {

  MapController _mapController = MapController();
  List<Marker> _markers = [];
  MapRectangleSelector rectangleSelector = MapRectangleSelector();
  List<LatLng> selectedAreaPoints = [];

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

    List<LayerOptions> mapLayers = [
      MyMap.openTopoMapOptions,
      MyMap.markedTrailsOptions,
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
      PolygonLayerOptions(
        polygons: [
          Polygon(
            points: selectedAreaPoints,
            borderColor: Colors.green,
            borderStrokeWidth: 2,
            color: Colors.green.withAlpha(100),
          )
        ]
      ),
    ];
    if(widget.centerCurrentLocationStreamController != null) {
      mapLayers.add(LocationMarkerLayerOptions());
    }

    return FlutterMap(
      options: MapOptions(
        onLongPress: (LatLng point) {
          rectangleSelector.handleTap(point);
          setState(() {
            selectedAreaPoints = rectangleSelector.getCorners();
          });
          widget.onRegionSelected(rectangleSelector.getBounds());
        },
        center: LatLng(47, 19.5),
        bounds: widget.bounds,
        zoom: 10,
        minZoom: 1,
        maxZoom: 16,
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
          if(hasGesture && widget.onLostFocus != null) {
            widget.onLostFocus();
          }
        }
      ),
      layers: mapLayers,
      mapController: _mapController,
    );
  }
}