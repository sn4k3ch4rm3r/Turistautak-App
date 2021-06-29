import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:turistautak/models/route.dart' as Model;
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
      body: ListView(
        children: [
          Text('yes'),
          Text('no'),
        ],
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
              print("${dist/1000} km (${elevGain} m / ${elevLoss} m)");
              Model.Route route = Model.Route(name, dist, elevGain.round(), elevLoss.round(), xml);
              await DatabaseProvider.db.insertRoute(route);
            }
          }
        },
      ),
    );
  }

  _showAddOptionsDialog(BuildContext context) => showDialog(
    context: context,
    builder:  (context) => AlertDialog(
      title: Text('Új útvonal felvétele'),
      actions: [
        TextButton(
          child: Text('Mégse'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('Megnyitás'),
          onPressed: () async {
            
          },
        ),
      ],
    )
  );

  _showFileDownloadDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog (
      title: Text('GPX fájl linkje'),
      content: TextFormField(
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: 'https://turistautak.openstreetmap.hu/mentettutv/1517050857v4y5/shortest-route.gpx',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {

          },
          child: Text('Letöltés')),
        TextButton(
          onPressed: () {
          Navigator.popUntil(context, (route) => route.settings.name == '/select_route');
        },
        child: Text('Mégse')),
      ],
    ),
  );
}