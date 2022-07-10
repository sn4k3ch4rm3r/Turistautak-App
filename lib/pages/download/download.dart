import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/pages/download/components/shape_selector.dart';
import 'package:turistautak/pages/download_options.dart';
import 'package:turistautak/shared/components/map.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/download.dart';
import 'package:turistautak/shared/sate/map_data.dart';
import 'package:turistautak/shared/vars/region_mode.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late final MapDataProvider provider = context.watch<MapDataProvider>();
  late final DownloadProvider downloadProvider = context.watch<DownloadProvider>();
  late final MapController _mapController;
  final GlobalKey<State<StatefulWidget>> _mapKey = GlobalKey<State<StatefulWidget>>();
  LatLng? _topLeft;
  LatLng? _bottomRight;
  LatLng? _center;
  double? _radius;
  
  @override
  void initState() {
    _mapController = MapController();
    Future.delayed(Duration.zero, () async {
      await _mapController.onReady;
      _mapController.move(Provider.of<MapDataProvider>(context, listen: false).center, 10);
      _updateRegion();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letöltés'),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context, 
              backgroundColor: Theme.of(context).colorScheme.surface,
              builder: (BuildContext context) => ShapeSelector()
            ).then((value) => _updateRegion()),
            icon: Icon(Icons.interests)
          )
        ],
      ),
      body: MapComponent(
        key: _mapKey,
        mapController: _mapController,
        onMove: (position, hasGesture) {
          if(hasGesture) _updateRegion();
        },
        layers: [
          provider.baseLayer.getTileLayerWidget(context: context),
          if (_topLeft != null &&
              _bottomRight != null &&
              downloadProvider.regionMode != RegionMode.circle)
            PolygonLayerWidget(
              options: RectangleRegion(
                LatLngBounds(
                  _topLeft,
                  _bottomRight,
                ),
              ).toDrawable(
                fillColor: Colors.green.withOpacity(0.5),
              ),
            )
          else if (_center != null &&
              _radius != null &&
              downloadProvider.regionMode == RegionMode.circle)
            PolygonLayerWidget(
              options: CircleRegion(
                _center!,
                _radius!,
              ).toDrawable(
                fillColor: Colors.green.withOpacity(0.5),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          downloadProvider.downloadProgress = MapLayers.openStreetMap.cachingInstance.download.startForeground(
            region: downloadProvider.region!.toDownloadable(
              1, 
              17,
              MapLayers.openStreetMap.getOptions(),
            ),
          ).asBroadcastStream();
          Navigator.push(context, MaterialPageRoute(builder: ((context) => DownloadOptions())));
        },
        icon: Icon(Icons.download), 
        label: Text('Letöltés')
      ),
    );
  }

  void _updateRegion() {
    final DownloadProvider downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    final double shapePadding = 15;

    final Size mapSize = _mapKey.currentContext!.size!;
    final mapCenter = Point<double>(mapSize.width / 2, mapSize.height / 2);

    late final Point<double> calculatedTopLeft;
    late final Point<double> calculatedBottomRight;

    switch (downloadProvider.regionMode) {
      case RegionMode.square:
        final allowedArea = Size.square(mapSize.width - (shapePadding * 2));
        calculatedTopLeft = Point<double>(
          shapePadding,
          mapCenter.y - allowedArea.height / 2,
        );
        calculatedBottomRight = Point<double>(
          mapSize.width - shapePadding,
          mapCenter.y + allowedArea.height / 2,
        );
        break;
      case RegionMode.rectangleVertical:
        final allowedArea = Size(
          mapSize.width - (shapePadding * 2),
          mapSize.height - (shapePadding * 2) - 50,
        );
        calculatedTopLeft = Point<double>(
          shapePadding,
          mapCenter.y - allowedArea.height / 2,
        );
        calculatedBottomRight = Point<double>(
          mapSize.width - shapePadding,
          mapCenter.y + allowedArea.height / 2,
        );
        break;
      case RegionMode.rectangleHorizontal:
        final allowedArea = Size(
          mapSize.width - (shapePadding * 2),
          (mapSize.width - (shapePadding * 2)) / 1.75,
        );
        calculatedTopLeft = Point<double>(
          shapePadding,
          mapCenter.y - allowedArea.height / 2,
        );
        calculatedBottomRight = Point<double>(
          mapSize.width - shapePadding,
          mapCenter.y + allowedArea.height / 2,
        );
        break;
      case RegionMode.circle:
        final allowedArea = Size.square(mapSize.width - (shapePadding * 2));

        final calculatedTop = Point<double>(
          mapCenter.x,
          mapCenter.y - allowedArea.height / 2,
        );

        _center = _mapController.center;
        _radius = const Distance(roundResult: false).distance(
          _center!,
          _mapController.pointToLatLng(_customPointFromPoint(calculatedTop))!,
        ) / 1000;
        break;
    }
    if (downloadProvider.regionMode != RegionMode.circle) {
      _topLeft = _mapController.pointToLatLng(_customPointFromPoint(calculatedTopLeft));
      _bottomRight = _mapController.pointToLatLng(_customPointFromPoint(calculatedBottomRight));
    }

    downloadProvider.region = downloadProvider.regionMode == RegionMode.circle
      ? CircleRegion(_center!, _radius!)
      : RectangleRegion(
          LatLngBounds(_topLeft, _bottomRight),
        );

    setState(() {});
  }

  CustomPoint<E> _customPointFromPoint<E extends num>(Point<E> point) =>
    CustomPoint(point.x, point.y);
}
