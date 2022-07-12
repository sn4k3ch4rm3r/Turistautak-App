import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/shared/map_layers.dart';

class MapDataProvider extends ChangeNotifier {
  LatLng _center = LatLng(47, 19.5);
  MapLayer _baseLayer = MapLayers.openStreetMap;
  Map<MapLayer, bool> _active = {
    MapLayers.trails: true,
  };

  LatLng get center => _center;
  set center(LatLng value) {
    _center = value;
    notifyListeners();
  }

  bool isActive(MapLayer layer) {
    if(_active.containsKey(layer)) {
      return _active[layer]!;
    }
    return false;
  }
  setLayer(MapLayer layer, bool active) {
    _active[layer] = active;
    notifyListeners();
  }

  MapLayer get baseLayer => _baseLayer;
  set baseLayer(MapLayer layer) {
    _baseLayer = layer;
    notifyListeners();
  }

  RouteModel? _route;
  RouteModel? get route => _route;
  set route(RouteModel? route) {
    _route = route;
    notifyListeners();
  }

  LatLng? _hoverPoint;
  LatLng? get hoverPoint => _hoverPoint;
  set hoverPoint(LatLng? point) {
    _hoverPoint = point;
    notifyListeners();
  }

}
