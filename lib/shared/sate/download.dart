import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
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
}