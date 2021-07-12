import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:turistautak/utils/caching_tile_provider.dart';

import 'latlng_to_tile.dart';

class MyMapDownloader {

  static int countTiles (LatLngBounds bounds, {int minZoom = 6, maxZoom = 16}) {
    int sum = 0;
    for (var z = minZoom; z <= maxZoom; z++) {
      Coords<num> nwTile = TilesLatLng.latlngToTile(bounds.northWest, z);
      Coords<num> seTile = TilesLatLng.latlngToTile(bounds.southEast, z);
      int w = seTile.x - nwTile.x +1;
      int h = seTile.y - nwTile.y +1;
      sum += w*h;
    }
    return sum;
  }

  static Future<void> downloadRegion(LatLngBounds bounds, List<TileLayerOptions> options, {int minZoom = 6, maxZoom = 16, BuildContext context}) async {
    CachingTileProvider provider = CachingTileProvider();
    int numberOfTiles = countTiles(bounds) * 2;
    int downloadedTiles = 0;
    for (var z = minZoom; z <= maxZoom; z++) {
      Coords<num> nwTile = TilesLatLng.latlngToTile(bounds.northWest, z);
      Coords<num> seTile = TilesLatLng.latlngToTile(bounds.southEast, z);
      for(int x = nwTile.x; x < seTile.x+1; x++) {
        for(int y = nwTile.y; y < seTile.y+1; y++){
          Coords<num> coords = Coords(x, y);
          coords.z = z;
          for (var option in options) {
            await provider.downloadImage(coords, option);
            downloadedTiles++;
            if(context != null) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Letöltve: $downloadedTiles/$numberOfTiles')));
            }
          }
        }
      }
    }
  }
}