import 'package: flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import '../services/bluetooth_service.dart';
import 'package:provider/provider.dart';

class Heatmap3D extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        var btService = Provider.of<BluetoothService>(context);
        return Cube(
            onSceneCreated: (Scene  scene) {
                scene.camera.position.z = 5;

                for ( var pt in btService.points) {
                    scene.world.add(Object(
                        position: Vector3(pt.x,pt.z,pt.y),
                        scale: Vector3(0.05,0.05,0.05),
                        filename: 'assets/point.obj',
                    ));
                }
            },
        );
    }
}