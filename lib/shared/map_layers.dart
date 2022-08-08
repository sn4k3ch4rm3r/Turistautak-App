import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapLayer {
  final String name;
  final bool overlay;

  MapLayer({required this.name, this.overlay = true});

  Image get image {
    return Image.asset('assets/images/$name.png');
  }
  
  @override
  String toString() {
    return 'MapLayer<$name>';
  }
}

class TileMapLayer extends MapLayer{
  final String sourceUrl;
  late StoreDirectory cachingInstance;
  TileLayerOptions getOptions({BuildContext? context}) {
    return TileLayerOptions(
      urlTemplate: sourceUrl,
      subdomains: ['a', 'b', 'c'],
      tileFadeInDuration: 300,
      tileProvider: cachingInstance.getTileProvider(),
      backgroundColor: overlay ? Colors.transparent : context != null ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey,
      fastReplace: overlay,
    );
  } 

  TileMapLayer({required super.name, required this.sourceUrl, required super.overlay}) {
    cachingInstance = FlutterMapTileCaching.instance(name);
  }

  TileLayerWidget getTileLayerWidget({BuildContext? context}) {
    return TileLayerWidget(
      options: getOptions(context: context)
    );
  }
}

class MapLayers {
  static TileMapLayer openStreetMap = TileMapLayer(
    name: 'OpenStreetMap', 
    sourceUrl: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static TileMapLayer openTopoMap = TileMapLayer(
    name: 'OpenTopoMap', 
    sourceUrl: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', 
    overlay: false
  );
  static TileMapLayer trails = TileMapLayer(
    name: 'Turistautak', 
    sourceUrl: 'https://{s}.tile.openstreetmap.hu/tt/{z}/{x}/{y}.png', 
    overlay: true
  );

  static MapLayer route = MapLayer(name: 'Útvonal');

  static List<TileMapLayer> allTileLayers = [
    openStreetMap,
    openTopoMap,
    trails,
  ];
}