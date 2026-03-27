import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Sonar3DView extends StatefulWidget {
  const Sonar3DView({super.key});

  @override
  State<Sonar3DView> createState() => _Sonar3DViewState();
}

class _Sonar3DViewState extends State<Sonar3DView> {
  Object? terrain;

  @override
  void initState() {
    super.initState();
  }

  void _onScreenCreated(Scene scene) {
    scene.camera.zoom = 10;

    terrain = Object(
      scale: Vector3(5.0, 1.0, 5.0),
      position: Vector3(0, 0, 0),
      fileName: 'assets/terrain.obj',
    );

    scene.world.add(terrain!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Puddle Eyes - 3D Scan")),
      body: Cube(onSceneCreated: _onScreenCreated),
    );
  }
}
