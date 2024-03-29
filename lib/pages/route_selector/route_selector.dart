import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/route_selector/componets/confirm_delete.dart';
import 'package:turistautak/shared/components/loading_indicator.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/map_data.dart';
import 'package:turistautak/utils/database_handler.dart';

class SelectRoutePage extends StatefulWidget {
  const SelectRoutePage({Key? key, required this.onSelected}) : super(key: key);

  final Function onSelected;

  @override
  _SelectRoutePageState createState() => _SelectRoutePageState();
}

class _SelectRoutePageState extends State<SelectRoutePage> {
  @override
  Widget build(BuildContext context) {
    MapDataProvider provider = Provider.of<MapDataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Útvonalak'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<List<RouteModel>>(
        future: DatabaseProvider.db.getRoutes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                RouteModel route = snapshot.data[index];
                return ListTile(
                  title: Text(route.name),
                  subtitle: Text('${round(route.length/1000, decimals: 2)} km - ${route.elevationGain} m / ${route.elevationLoss} m'),
                  onTap: () async {
                    provider.route = route;
                    provider.setLayer(MapLayers.route, true);
                    widget.onSelected();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('CurrentRoute', route.name);
                  },
                  onLongPress: () async {
                    if(await showDialog(context: context, builder: (context) => ConfirmDeleteDialog(routeName: route.name))) {
                      await DatabaseProvider.db.deleteRoute(route);
                      setState(() {});
                    }
                  },
                  textColor: Theme.of(context).colorScheme.onBackground,
                );
              },
            );
          }
          else {
            return LoadingIndicator(message: 'Útvonalak betöltése...');
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.folder),
        label: Text('Megnyitás'),       
        onPressed: () async {
          var permission = Permission.storage.request();
          if(await permission.isGranted) {
            await FilePicker.platform.clearTemporaryFiles();
            FilePickerResult? res = await FilePicker.platform.pickFiles();
            if(res != null) {
              try {
                String name = res.files.single.name.split('.gpx')[0];

                String xml = await File(res.files.first.path!).readAsString();
                Gpx gpx = GpxReader().fromString(xml);
                double elevGain = 0;
                double elevLoss = 0;
                double dist = 0;

                var track = gpx.trks[0].trksegs[0].trkpts;
                final Distance distance = Distance();

                for(int i = 1; i < track.length; i++) {
                  if (track[i-1].ele! < track[i].ele!){
                    elevGain += track[i].ele! - track[i-1].ele!;
                  }
                  else {
                    elevLoss += track[i-1].ele! - track[i].ele!;
                  }
                  dist += distance(
                    LatLng(track[i-1].lat!, track[i-1].lon!),
                    LatLng(track[i].lat!, track[i].lon!)
                  );
                }
                print("${dist/1000} km ($elevGain m / $elevLoss m)");
                RouteModel route = RouteModel(name, dist, elevGain.round(), elevLoss.round(), xml);
                await DatabaseProvider.db.insertRoute(route);
                setState(() => {});
              }
              catch (exception){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hibás fájl.'))
                );
              }
            }
          }
        },
      ),
    );
  }
}