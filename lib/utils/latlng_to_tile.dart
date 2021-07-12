import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class TilesLatLng {
  static Coords<num> latlngToTile(LatLng latlng, int zoom) {
    final n = pow(2.0, zoom);
    int x = ((latlng.longitude+180.0)/360.0*n).toInt();
    int y = ((1.0 - log(tan(latlng.latitudeInRad) + (1.0 / cos(latlng.latitudeInRad)))/pi) / 2.0 * n).toInt(); 
    return Coords(x, y);
  }
}