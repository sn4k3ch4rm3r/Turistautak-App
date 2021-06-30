import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:turistautak/models/route.dart';
import 'package:turistautak/pages/route_details.dart';
import 'package:turistautak/utils/database_handler.dart';

class SelectRoute extends StatefulWidget {
  @override
  _SelectRouteState createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Útvonalak'),
      ),
      body: FutureBuilder(
        future: DatabaseProvider.db.getRoutes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          List<Widget> children = <Widget>[];
          if(snapshot.hasData) {
            for (RouteModel route in snapshot.data) {
              ListTile rtElement = ListTile(
                title: Text(route.name),
                subtitle: Text('${round(route.length/1000, decimals: 2)} km - ${route.elevationGain} m / ${route.elevationLoss} m'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetails(route: route),
                    )
                  );
                },
              );
              children.add(rtElement);
            }
            return ListView(
              children: children,
            );
          }
          else {
            return Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () async {
          var permission = Permission.storage.request();
          if(await permission.isGranted) {
            await FilePicker.platform.clearTemporaryFiles();
            FilePickerResult res = await FilePicker.platform.pickFiles();
            if(res != null) {
              String name = res.files.single.name.split('.gpx')[0];

              String xml = await File(res.files.first.path).readAsString();
              Gpx gpx = GpxReader().fromString(xml);
              double elevGain = 0;
              double elevLoss = 0;
              double dist = 0;

              var track = gpx.trks[0].trksegs[0].trkpts;
              final Distance distance = Distance();

              for(int i = 1; i < track.length; i++) {
                if (track[i-1].ele < track[i].ele){
                  elevGain += track[i].ele - track[i-1].ele;
                }
                else {
                  elevLoss += track[i-1].ele - track[i].ele;
                }
                dist += distance(
                  LatLng(track[i-1].lat, track[i-1].lon),
                  LatLng(track[i].lat, track[i].lon)
                );
              }
              print("${dist/1000} km ($elevGain m / $elevLoss m)");
              RouteModel route = RouteModel(name, dist, elevGain.round(), elevLoss.round(), xml);
              await DatabaseProvider.db.insertRoute(route);
            }
          }
        },
      ),
    );
  }
}