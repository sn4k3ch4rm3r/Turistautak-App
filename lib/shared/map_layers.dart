import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapLayer {
  final String name;
  final String sourceUrl;
  final bool overlay;
  
  const MapLayer({required this.name, required this.sourceUrl, required this.overlay});

  TileLayerWidget getTileLayerWidget(ColorScheme colorScheme) {
    return TileLayerWidget(
      options: TileLayerOptions(
        urlTemplate: sourceUrl,
        subdomains: ['a', 'b', 'c'],
        tileFadeInDuration: 300,
        tileProvider: FlutterMapTileCaching.instance(name).getTileProvider(),
        backgroundColor: overlay ? Colors.transparent : colorScheme.surfaceVariant,
        fastReplace: overlay,
      ) 
    );
  }
}

class MapLayers {
  static const MapLayer openStreetMap = MapLayer(
    name: 'OpenStreetMap', 
    sourceUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static const MapLayer openTopoMap = MapLayer(
    name: 'OpenTopoMap', 
    sourceUrl: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static const MapLayer trails = MapLayer(
    name: 'Turistautak', 
    sourceUrl: 'https://{s}.tile.openstreetmap.hu/tt/{z}/{x}/{y}.png', 
    overlay: true
  );

  static const List<MapLayer> all = [
    openStreetMap,
    openTopoMap,
    trails,
  ];
}