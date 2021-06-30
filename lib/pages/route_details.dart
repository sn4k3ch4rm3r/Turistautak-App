import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:turistautak/components/map.dart';
import 'package:turistautak/models/route.dart';
import 'package:latlong2/latlong.dart';

class RouteDetails extends StatefulWidget {

  final RouteModel route;

  const RouteDetails({Key key, this.route}) : super(key: key);

  @override
  _RouteDetailsState createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  LatLng hoverPoint;

  @override
  Widget build(BuildContext context) {
    LatLngBounds bounds = LatLngBounds.fromPoints(widget.route.getPoints());
    bounds.pad(0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.route.name,
          textScaleFactor: 0.8,
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: (){},
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 290,
            child: MyMap(
              points: widget.route.getPoints(),
              hoverPoint: hoverPoint,
              bounds: bounds,
            ),
          ),
          Container(
            height: 100,
            child: NotificationListener<ElevationHoverNotification>(
              onNotification: (ElevationHoverNotification notification) {
                if(notification.position != null) {
                  setState(() {
                    hoverPoint = LatLng(notification.position.latitude, notification.position.longitude);
                  });
                }
                return true;
              },
              child: Elevation(
                widget.route.getElevationPoints(),
                color: Colors.green,
                elevationGradientColors: ElevationGradientColors(
                  gt10: Colors.green,
                  gt20: Colors.orange,
                  gt30: Colors.red,
                ),
              ),
            ),
          ),
          Text(
            '${round(widget.route.length / 1000, decimals: 2)} km',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
          ),
          Text('▲ ${widget.route.elevationGain} m / ▼ ${widget.route.elevationLoss} m'),
          ElevatedButton(
            child: Text('Indulás'),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}