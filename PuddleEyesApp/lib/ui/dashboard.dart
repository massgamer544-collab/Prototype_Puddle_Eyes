import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'heatmap_3d.dart';
import 'alerts.dart';
import '../services/bluetooth_service.dart';
import '../services/car_integration.dart';
import 'trajectory_overlay.dart';


class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var btService = Provider.of<BluetoothService>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (btService.points.isNotEmpty) {
        var pointsData = btService.points.map((p) => {'x': p.x, 'y': p.y, 'z': p.z}).toList();
        await CarIntegration.sendDataToCar(pointsData);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Puddle Eyes Dashboard')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(flex: 3, child: Heatmap3D()),
              Expanded(flex: 1, child: AlertsWidget()),
            ],
          ),
          TrajectoryOverlay(), // Overlay dynamique
        ],
      ),
    );
  }
}