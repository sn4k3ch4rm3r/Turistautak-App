import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapLayer {
  final String name;
  final String sourceUrl;
  final bool overlay;
  late StoreDirectory cachingInstance;
  
  MapLayer({required this.name, required this.sourceUrl, required this.overlay}) {
    cachingInstance = FlutterMapTileCaching.instance(name);
  }

  TileLayerWidget getTileLayerWidget({BuildContext? context}) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: sourceUrl,
        subdomains: ['a', 'b', 'c'],
        tileFadeInDuration: 300,
        tileProvider: cachingInstance.getTileProvider(),
        backgroundColor: overlay ? Colors.transparent : context != null ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey,
        fastReplace: overlay,
      ) 
    );
  }
}

class MapLayers {
  static MapLayer openStreetMap = MapLayer(
    name: 'OpenStreetMap', 
    sourceUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static MapLayer openTopoMap = MapLayer(
    name: 'OpenTopoMap', 
    sourceUrl: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static MapLayer trails = MapLayer(
    name: 'Turistautak', 
    sourceUrl: 'https://{s}.tile.openstreetmap.hu/tt/{z}/{x}/{y}.png', 
    overlay: true
  );

  static List<MapLayer> all = [
    openStreetMap,
    openTopoMap,
    trails,
  ];
}