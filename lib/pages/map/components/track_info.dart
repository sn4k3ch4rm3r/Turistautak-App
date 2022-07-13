import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/download_options.dart';
import 'package:turistautak/shared/sate/download.dart';
import 'package:turistautak/shared/sate/map_data.dart';

class TrackInfoPanel extends StatelessWidget {
  final RouteModel route;
  const TrackInfoPanel({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MapDataProvider provider = Provider.of<MapDataProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  route.name,
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.onSurface
                  ),
                ),
                width: MediaQuery.of(context).size.width/2,
              ),
              Column(
                children: [
                  Text(
                    '${(route.length/1000).toStringAsFixed(2)} km',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                  Text(
                    '▲ ${route.elevationGain} m / ▼ ${route.elevationLoss} m',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface
                    ),
                  )
                ],
              )
            ],
          ),
          Spacer(),
          Container(
            height: 120,
            child: NotificationListener<ElevationHoverNotification>(
              onNotification: (ElevationHoverNotification notification) {
                MapDataProvider provider = Provider.of<MapDataProvider>(context, listen: false);
                if(notification.position != null) {
                  provider.hoverPoint = LatLng(notification.position!.latitude, notification.position!.longitude);
                }
                else provider.hoverPoint = null;
                return true;
              },
              child: Elevation(
                route.getElevationPoints(),
                color: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  provider.route = null;
                }, 
                child: Text('Befejezés')
              ),
              SizedBox(width: 15),
              OutlinedButton(
                onPressed: () async {
                  DownloadProvider downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
                  downloadProvider.region = RectangleRegion(route.getBounds());
                  bool downloading = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DownloadOptions()
                    )
                  );
                  if(downloading){
                    provider.startDownload();
                  }
                },
                child: Text('Letöltés')
              ),
            ],
          ),
        ],
      ),
    );
  }
}