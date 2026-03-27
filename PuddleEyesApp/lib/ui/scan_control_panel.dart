import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ScanControlPanel extends StatelessWidget {
  const ScanControlPanel({super.key});

  Widget _button({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            textAlign: TextAlign.center,
          ),
          style: FilledButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF1B2530),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bt = Provider.of<BluetoothService>(context, listen: false);

    return Column(
      children: [
        Row(
          children: [
            _button(
              context: context,
              icon: Icons.wifi,
              label: 'Live',
              color: const Color(0xFF005B70),
              onTap: bt.startLiveHttpScan,
            ),
            _button(
              context: context,
              icon: Icons.horizontal_rule,
              label: 'Flat',
              onTap: bt.startSimulationFlat,
            ),
            _button(
              context: context,
              icon: Icons.warning_amber,
              label: 'Hole',
              onTap: bt.startSimulationMudHole,
            ),
          ],
        ),
        Row(
          children: [
            _button(
              context: context,
              icon: Icons.turn_left,
              label: 'Left Path',
              onTap: bt.startSimulationLeftSafePath,
            ),
            _button(
              context: context,
              icon: Icons.landscape,
              label: 'Wide Hole',
              onTap: bt.startSimulationDeepWideHole,
            ),
            _button(
              context: context,
              icon: Icons.blur_on,
              label: 'Detailed',
              onTap: bt.startSimulationUltraDetailedHole,
            ),
          ],
        ),
        Row(
          children: [
            _button(
              context: context,
              icon: Icons.crisis_alert,
              label: 'Stick',
              color: const Color(0xFF5D1C1C),
              onTap: bt.startSimulationHoleWithStick,
            ),
          ],
        ),
      ],
    );
  }
}