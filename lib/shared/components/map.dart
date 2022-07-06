import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:turistautak/shared/map_layers.dart';

class MapComponent extends StatelessWidget {
  const MapComponent({Key? key, this.locationMaker, this.onMove, this.mapController}) : super(key: key);

  final LocationMarkerLayerWidget? locationMaker;
  final Function? onMove;
  final MapController? mapController;

  List<Widget> getLayers(ColorScheme colorScheme) {
    List<Widget> layers = [
      MapLayers.openStreetMap.getTileLayerWidget(colorScheme),
      MapLayers.trails.getTileLayerWidget(colorScheme),
    ];

    if(locationMaker != null) {
      layers.add(locationMaker!);
    }

    return layers;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(47, 19.5),
        minZoom: 1,
        maxZoom: 17,
        zoom: 14,
        interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if(hasGesture && onMove != null) {
            onMove!(position);
          }
        }
      ),
      children: getLayers(Theme.of(context).colorScheme),
    );
  }
}
