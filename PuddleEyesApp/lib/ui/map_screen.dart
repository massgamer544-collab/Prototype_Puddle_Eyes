import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Offroad Map')),
      body: Center(
        child: Text('Carte indisponible pour l’instant.'),
      ),
    );
  }
}
