import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRectangleSelector {

  List<LatLng> selected = [];
  void handleTap(LatLng point) {
    if (selected.length < 2) {
      selected.add(point);
    }
    else {
      selected = [];
    }
  }

  LatLngBounds getBounds() {
    if(selected.length < 2) {
      return null;
    }
    return LatLngBounds.fromPoints(selected);
  }

  List<LatLng> getCorners() {
    LatLngBounds bounds = getBounds();
    if(bounds == null) {
      return [];
    }
    
    return [
      bounds.northEast,
      bounds.northWest,
      bounds.southWest,
      bounds.southEast,
    ];
  }
}