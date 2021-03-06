import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String name;
  final double length;
  final int elevationGain;
  final int elevationLoss;
  final String gpxData;

  RouteModel(this.name, this.length, this.elevationGain, this.elevationLoss, this.gpxData);

  Map<String, dynamic> toMap() {
    return  {
      'name': name,
      'length': length,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'GPXData': gpxData
    };
  }

  List<LatLng> getPoints() {
    List<LatLng> points = <LatLng>[];
    Gpx gpx = GpxReader().fromString(gpxData);
    var track = gpx.trks[0].trksegs[0].trkpts;
    for (var pt in track) {
      points.add(LatLng(pt.lat!, pt.lon!));
    }
    return points;
  }

  List<ElevationPoint> getElevationPoints() {
    List<ElevationPoint> points = <ElevationPoint>[];
    Gpx gpx = GpxReader().fromString(gpxData);
    var track = gpx.trks[0].trksegs[0].trkpts;
    for (var pt in track) {
      points.add(ElevationPoint(pt.lat!, pt.lon!, pt.ele!));
    }
    return points;
  }

  LatLngBounds getBounds() {
    LatLngBounds bounds = LatLngBounds.fromPoints(getPoints());
    bounds.pad(0.1);
    return bounds;
  }

  @override
  String toString() {
    return "$RouteModel($name | $length m)";
  }
}