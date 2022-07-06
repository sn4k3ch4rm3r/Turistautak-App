import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:turistautak/shared/components/map.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool centerOnUpdate = true;
  late StreamController<double?> locationStream;
  late final MapController mapController;

  @override
  void initState() {
    mapController = MapController();
    locationStream = StreamController<double?>();
    super.initState();
  }

  @override
  void dispose() {
    locationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: mapController.onReady,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text('Térkép')),
          body: MapComponent(
            mapController: mapController,
            locationMaker: LocationMarkerLayerWidget(
              plugin: LocationMarkerPlugin(
                centerOnLocationUpdate: centerOnUpdate? CenterOnLocationUpdate.always : CenterOnLocationUpdate.once,
                centerCurrentLocationStream: locationStream.stream,
              ),
            ),
            onMove: (MapPosition position) {
              setState(() {
                centerOnUpdate = false;
              });
            },
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  if(!centerOnUpdate) {
                    setState(() {
                      centerOnUpdate = true;
                      locationStream.add(mapController.zoom);
                    });
                  }
                  else {
                    locationStream.add(14);
                  }
                },
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                child: Icon(
                    centerOnUpdate ? Icons.gps_fixed : Icons.gps_not_fixed
                  ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.layers_sharp),
              ),
            ],
          ),
        );
      },
    );
  }
}