import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ScanSummaryCards extends StatelessWidget {
  const ScanSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final bt = Provider.of<BluetoothService>(context);

    final maxDepth = bt.maxDepth;
    final leftDepth = bt.leftDepth;
    final rightDepth = bt.rightDepth;
    final saferSide = bt.saferSide;
    final risk = bt.riskLabel;

    Color riskColor = const Color(0xFF00E676);
    if (risk == 'CAUTION') {
      riskColor = Colors.orangeAccent;
    } else if (risk == 'DANGER') {
      riskColor = Colors.redAccent;
    }

    Color sideColor = Colors.white;
    if (saferSide == 'LEFT' || saferSide == 'RIGHT') {
      sideColor = const Color(0xFF4DD0E1);
    } else if (saferSide == 'CENTER') {
      sideColor = const Color(0xFF00E676);
    } else if (saferSide == 'NONE') {
      sideColor = Colors.redAccent;
    }

    Widget card(String title, String value, {Color? valueColor}) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131A22),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF26323D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            card('Depth', '${maxDepth.toStringAsFixed(2)} m'),
            card('Risk', risk, valueColor: riskColor),
            card('Safe side', saferSide, valueColor: sideColor),
          ],
        ),
        Row(
          children: [
            card('Left', '${leftDepth.toStringAsFixed(2)} m'),
            card('Center', '${bt.centerDepth.toStringAsFixed(2)} m'),
            card('Right', '${rightDepth.toStringAsFixed(2)} m'),
          ],
        ),
      ],
    );
  }
}