import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/vars/region_mode.dart';

class DownloadProvider extends ChangeNotifier {
  Stream<DownloadProgress>? _downloadProgress;
  Stream<DownloadProgress>? get downloadProgress => _downloadProgress;
  set downloadProgress(Stream<DownloadProgress>? newStream) {
    _downloadProgress = newStream;
    notifyListeners();
  }

  RegionMode _regionMode = RegionMode.square;
  RegionMode get regionMode => _regionMode;
  set regionMode(RegionMode newMode) {
    _regionMode = newMode;
    notifyListeners();
  }

  BaseRegion? _region;
  BaseRegion? get region => _region;
  set region(BaseRegion? newRegion) {
    _region = newRegion;
    notifyListeners();
  }

  Map<MapLayer, bool> _selectedLayers = {
    MapLayers.openStreetMap: true,
    MapLayers.openTopoMap: true,
    MapLayers.trails: true,
  };
  Map<MapLayer, bool> get selectedLayers => _selectedLayers;
  bool isSelected(MapLayer layer) {
    if(_selectedLayers.containsKey(layer)) {
      return _selectedLayers[layer]!;
    }
    return false;
  }

  RangeValues _zoomRange = RangeValues(1, 17);
  RangeValues get zoomRange => _zoomRange;
  set zoomRange(RangeValues value) {
    _zoomRange = value;
    notifyListeners();
  }
  
}