import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ScanStatusBar extends StatelessWidget {
  const ScanStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final btService = Provider.of<BluetoothService>(context);

    Color confidenceColor = Colors.redAccent;
    if (btService.scanQuality >= 0.7) {
      confidenceColor = Colors.greenAccent;
    } else if (btService.scanQuality >= 0.4) {
      confidenceColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF10161D),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF26323D)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            btService.isLive ? Icons.wifi : Icons.science,
            color: btService.isLive ? const Color(0xFF4DD0E1) : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            btService.sourceLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${btService.points.length} pts',
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Text(
            btService.scanQualityLabel,
            style: TextStyle(
              color: confidenceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}