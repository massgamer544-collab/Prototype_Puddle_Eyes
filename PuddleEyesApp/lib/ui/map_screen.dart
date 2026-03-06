import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/tracking_service.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var obstacles = TrackingService.getAllObstacles();

    return Scaffold(
      appBar: AppBar(title: Text('Offroad Map')),
      body: FlutterMap(
        options: MapOptions(center: LatLng(45.0, -73.0), zoom: 13),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: obstacles.map((obs) => Marker(
              width: 40,
              height: 40,
              point: LatLng(obs.lat, obs.lon),
              builder: (ctx) => Icon(Icons.warning, color: Colors.red),
            )).toList(),
          ),
        ],
      ),
    );
  }
}