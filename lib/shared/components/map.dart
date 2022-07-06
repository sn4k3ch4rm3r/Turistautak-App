import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:turistautak/shared/map_layers.dart';

class MapComponent extends StatelessWidget {
  MapComponent({Key? key, this.onMove, this.mapController, this.layers}) : super(key: key);

  final Function? onMove;
  final MapController? mapController;
  final List<Widget>? layers;

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
      children: layers ?? [MapLayers.openStreetMap.getTileLayerWidget()],
    );
  }
}
