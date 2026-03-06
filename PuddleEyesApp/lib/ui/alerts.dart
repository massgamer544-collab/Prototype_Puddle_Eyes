import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'package:provider/provider.dart';

class AlertWidget extemds StatelessWidget {
    @override
    Widget build(BuildContext context) {
        var btService = Provider.of<BluetoothService>(context);

        //Exemple : prendre la profondeur minimal detectée
        double minDepth = 5.0;
        if(btService.points.isNotEmpty) {
            minDepth = btService.points.map((p) => p.z).reduce((a,b) => a<b?a:b);
        }

        Color color = Colors.green;
        String status = "SAFE";

        if (minDepth > 0.2 && minDepth <= 0.4) {
            color = Colors.yellow;
            status = "CAUTION";
        } else if (minDepth > 0.4) {
            color = Colors.red;
            status = "DANGER";
        }

        return Container(
            padding: EdgeInsets.all(16),
            color: color,
            child: Text(
                status,
                style: TextStyle(fontSize: 24, color: Colors.white),
            ),
        );
    }
}