import 'package:flutter/material.dart';
import 'package:turistautak/shared/map_layers.dart';

class LayerProvider extends ChangeNotifier {
  MapLayer _baseLayer = MapLayers.openStreetMap;
  Map<MapLayer, bool> _active = {
    MapLayers.trails: true,
  };

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
}
