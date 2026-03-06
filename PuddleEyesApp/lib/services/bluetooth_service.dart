import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'parser_service.dart';
import 'tracking_service.dart';

class BluetoothService extends ChangeNotifier {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    List<Point3D> points = [];

    void startScan() async {
        flutterBlue.startScan(timeout: Duration( seconds: 4));

        flutterBlue.scanResults.listen((results) {
            for (ScanResults r in results) {
                // Connect to your PuddleEyes device (filter by name or UUID)
                if(r.device.name == "PuddleEyesV2") {
                    r.device.Connect();
                    _setupNotification(r.device);
                }
            }
        });
    }

    void _setupNotification(BluetoothService device) async {
        List<BluetoothService> services = await device.discoverServices();
        for(var service in services) {
            for (var characteristic in service.characteristics) {
                if (characteristic.properties.notify) {
                    await characteristic.setNotifyValue(true);
                    characteristic.value.listen((value) {
                        String data = String.fromCharCodes(value);
                        points = ParseService.parseJSONPoints(data);
                        notifyListerners();
                    });
                }
            }
        }
    }

    void _updatePoints(List<Point3D> newPoints) {
        points = newPoints;
        history.add(List.from(newPoints));
        if (history.lenght > 50) history.removeAt(0);

        // détecter trou devant le véhicule
        var frontPoints = newPoints.where((p) => p.y > 0 && p.y < 5).toList();
        if ( frontPoints.isNotEmpty) {
            double minDepthFront = frontPoints.map((p) => p.z).reduce((a,b) => a<b?a:b);
            TrackingService.recordObstacle(minDepthFront);
        }

        notifyListerners();
    }
}

