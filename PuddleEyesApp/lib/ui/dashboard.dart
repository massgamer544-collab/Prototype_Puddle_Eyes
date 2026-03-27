import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/car_integration.dart';
import 'alerts.dart';
import 'heatmap_3d.dart';
import 'scan_control_panel.dart';
import 'scan_status_bar.dart';
import 'scan_summary_cards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btService = Provider.of<BluetoothService>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (btService.points.isNotEmpty) {
        await CarIntegration.sendDataToCar(btService.points);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puddle Eyes'),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFF0B0F14),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF26323D)),
                  ),
                  child: const Column(
                    children: [
                      ScanStatusBar(),
                      Expanded(
                        child: Heatmap3D(),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ScanSummaryCards(),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF26323D)),
                  ),
                  //child: const AlertsWidget(),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131A22),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26323D)),
                ),
                child: const ScanControlPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}