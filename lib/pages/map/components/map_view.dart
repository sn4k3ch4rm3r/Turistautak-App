import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/map/components/layer_selector.dart';
import 'package:turistautak/pages/map/components/track_info.dart';
import 'package:turistautak/shared/components/map.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/map_data.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool centerOnUpdate = true;
  bool _pageLoaded = false;
  late StreamController<double?> locationStream;
  late final MapController mapController;
  late MapDataProvider provider = Provider.of<MapDataProvider>(context, listen: true);
  final PanelController panelController = PanelController();

  RouteModel? _route;
  double _fabHeight = 15;

  @override
  void initState() {
    mapController = MapController();
    locationStream = StreamController<double?>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addListener(_changeListener);
      _pageLoaded = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    locationStream.close();
    provider.removeListener(_changeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: mapController.onReady,
      builder: (context, snapshot) {

        double panelHeightOpen = 290;
        double panelHeightClosed = provider.route != null ? 85 : 0;

        return Scaffold(
          body: Stack(
            children: [
              SlidingUpPanel(
                controller: panelController,
                panelBuilder: (sc) => provider.route != null ? TrackInfoPanel(route: provider.route!) : Container(),
                parallaxEnabled: true,
                parallaxOffset: 0.6,
                minHeight: panelHeightClosed,
                maxHeight: panelHeightOpen,
                color: Theme.of(context).colorScheme.surface,
                body: MapComponent(
                  mapController: mapController,
                  layers: [
                    provider.baseLayer.getTileLayerWidget(context: context),
                      if(provider.isActive(MapLayers.trails))
                        MapLayers.trails.getTileLayerWidget(),
              
                    if(true)
                      PolylineLayerWidget(
                        options: PolylineLayerOptions(
                          polylines: [
                            Polyline(
                              points: provider.route?.getPoints() ?? [],
                              color: Color.fromARGB(230, 50, 100, 255),
                              strokeWidth: 3.0,
                            )
                          ]
                        ),
                      ),
                    if(provider.hoverPoint != null)
                      MarkerLayerWidget(
                        options: MarkerLayerOptions(
                          markers: [
                            Marker(
                              point: provider.hoverPoint!,
                              width: 10,
                              height: 10,
                              builder: (BuildContext context) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    LocationMarkerLayerWidget(
                      plugin: LocationMarkerPlugin(
                        centerOnLocationUpdate: centerOnUpdate? CenterOnLocationUpdate.always : CenterOnLocationUpdate.never,
                        centerCurrentLocationStream: locationStream.stream,
                      ),
                    )
                  ],
                  onMove: (MapPosition position, bool hasGesture) {
                    if(hasGesture){
                      setState(() {
                        centerOnUpdate = false;
                      });
                    }
                    if(_pageLoaded){
                      context.read<MapDataProvider>().center = mapController.center;
                    }
                  },
                ),
                onPanelSlide: (position) => setState(() {
                  _fabHeight = (panelHeightOpen - panelHeightClosed) * position + 15;
                }),
              ),
              Positioned(
                right: 15,
                bottom: _fabHeight + panelHeightClosed,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 'btn_center',
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
                      heroTag: 'btn_layers',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context, 
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          builder: (_) => LayerSelector(),
                        );
                      },
                      child: const Icon(Icons.layers_sharp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeListener() {
    if(_route != provider.route) {
      setState(() {
        _route = provider.route;
        centerOnUpdate = _route == null ? centerOnUpdate : false;
      });
      if(_route != null) {
        CenterZoom pos = mapController.centerZoomFitBounds(_route!.getBounds());
        mapController.move(pos.center, pos.zoom);
      }
      else {
        panelController.close();
      }
    }
  }
}