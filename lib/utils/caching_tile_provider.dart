import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:turistautak/main.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'latlng_to_tile.dart';

class CachingTileProvider extends TileProvider {
  const CachingTileProvider();
  static final String downloadDirectory = 'offlineMaps';

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    File tileFile = File(getAbsoluteLocalPath(coords, options));

    if(tileFile.existsSync()) {
      print('Loaded ${tileFile.path} from storage');
      return FileImage(tileFile);
    }
    
    return CachedNetworkImageProvider(getTileUrl(coords, options));
  }

  String getAbsoluteLocalPath(Coords<num> coords, TileLayerOptions options) {
    String tileUrlPath = getTileUrl(coords, options).replaceFirst('https://${getSubdomain(coords, options)}.', '');
    return join(MyApp.baseDirectory.path, downloadDirectory, tileUrlPath);
  }

  Future<void> downloadImage(Coords<num> coords, TileLayerOptions options) async {
    print('Downloading to ${getAbsoluteLocalPath(coords, options)}');
    HttpClient httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(getTileUrl(coords, options)));
    var response = await request.close();
    if(response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      File file = File(getAbsoluteLocalPath(coords, options));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    else {
      print('Something went wrong (HTTP ${response.statusCode})');
    }
  }
}