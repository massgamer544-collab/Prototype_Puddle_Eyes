import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/esp32/esp32_service.dart';
import '../services/esp32/esp32_models.dart';
import '../services/analysis/terrain_analyzer.dart';
import '../state/scan_state.dart';

class Point3D {
  final double x;
  final double y;
  final double z;

  Point3D(this.x, this.y, this.z);

  factory Point3D.fromScan(ScanPoint p) {
    return Point3D(p.x, p.y, p.z);
  }
}

class CameraOverlayScreen extends StatefulWidget {
  const CameraOverlayScreen({super.key});

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> {
  late Esp32Service _esp32Service;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _esp32Service = Esp32Service();

    final scanState = context.read<ScanState>();

    _sub = _esp32Service.streamScan().listen((data) {
      scanState.update(data);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = context.watch<ScanState>();

    final analysis = TerrainAnalyzer.analyze(scanState.points);

    final points3D =
        scanState.points.map((e) => Point3D.fromScan(e)).toList();

    final saferSide = analysis.safestZone?.name.toUpperCase() ?? "NONE";
    final risk = analysis.risk;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const _MockCameraBackground(),

              _DepthOverlay(
                points: points3D,
                leftDepth: analysis.zones[Zone.left]!.avgDepth,
                centerDepth: analysis.zones[Zone.center]!.avgDepth,
                rightDepth: analysis.zones[Zone.right]!.avgDepth,
                hasLeftObstacle: analysis.zones[Zone.left]!.hasObstacle,
                hasCenterObstacle: analysis.zones[Zone.center]!.hasObstacle,
                hasRightObstacle: analysis.zones[Zone.right]!.hasObstacle,
                saferSide: saferSide,
                risk: risk,
              ),

              SafeArea(
                child: Column(
                  children: [
                    _TopStatusBar(
                      sourceLabel: "ESP32",
                      scanQualityLabel:
                          scanState.hasData ? "LIVE" : "NO DATA",
                      isLive: true,
                    ),
                    const Spacer(),
                    _BottomHud(
                      depth: _maxDepth(points3D),
                      risk: risk,
                      saferSide: saferSide,
                      pointCount: points3D.length,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _maxDepth(List<Point3D> points) {
    if (points.isEmpty) return 0;
    return points.map((e) => e.z).reduce((a, b) => a > b ? a : b);
  }
}

/* ================= UI ================= */

class _MockCameraBackground extends StatelessWidget {
  const _MockCameraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2B3138),
            Color(0xFF3D342B),
            Color(0xFF2F261E),
            Color(0xFF1C1A18),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _DepthOverlay extends StatelessWidget {
  final List<Point3D> points;
  final double leftDepth;
  final double centerDepth;
  final double rightDepth;
  final bool hasLeftObstacle;
  final bool hasCenterObstacle;
  final bool hasRightObstacle;
  final String saferSide;
  final String risk;

  const _DepthOverlay({
    required this.points,
    required this.leftDepth,
    required this.centerDepth,
    required this.rightDepth,
    required this.hasLeftObstacle,
    required this.hasCenterObstacle,
    required this.hasRightObstacle,
    required this.saferSide,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DepthOverlayPainter(
        leftDepth: leftDepth,
        centerDepth: centerDepth,
        rightDepth: rightDepth,
        hasLeftObstacle: hasLeftObstacle,
        hasCenterObstacle: hasCenterObstacle,
        hasRightObstacle: hasRightObstacle,
        saferSide: saferSide,
        risk: risk,
      ),
      size: Size.infinite,
    );
  }
}

class _DepthOverlayPainter extends CustomPainter {
  final double leftDepth;
  final double centerDepth;
  final double rightDepth;
  final bool hasLeftObstacle;
  final bool hasCenterObstacle;
  final bool hasRightObstacle;
  final String saferSide;
  final String risk;

  _DepthOverlayPainter({
    required this.leftDepth,
    required this.centerDepth,
    required this.rightDepth,
    required this.hasLeftObstacle,
    required this.hasCenterObstacle,
    required this.hasRightObstacle,
    required this.saferSide,
    required this.risk,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawZone(canvas, size, 0.2, leftDepth, hasLeftObstacle);
    _drawZone(canvas, size, 0.5, centerDepth, hasCenterObstacle);
    _drawZone(canvas, size, 0.8, rightDepth, hasRightObstacle);
    _drawArrow(canvas, size);
  }

  void _drawZone(Canvas canvas, Size size, double xFactor, double depth, bool hasObstacle) {
    final color = hasObstacle
        ? Colors.redAccent
        : depth < 0.12
            ? const Color(0xFF00E676)
            : depth < 0.25
                ? Colors.orangeAccent
                : Colors.redAccent;

    final paint = Paint()..color = color.withOpacity(0.25);

    final rect = Rect.fromCenter(
      center: Offset(size.width * xFactor, size.height * 0.7),
      width: size.width * 0.25,
      height: size.height * 0.4,
    );

    canvas.drawRect(rect, paint);
  }

  void _drawArrow(Canvas canvas, Size size) {
    if (saferSide == "NONE" || saferSide == "CENTER") return;

    final paint = Paint()
      ..color = const Color(0xCC00E676)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height * 0.85;

    if (saferSide == "LEFT") {
      path.moveTo(cx - 80, cy);
      path.lineTo(cx - 20, cy - 20);
      path.lineTo(cx - 20, cy + 20);
    } else {
      path.moveTo(cx + 80, cy);
      path.lineTo(cx + 20, cy - 20);
      path.lineTo(cx + 20, cy + 20);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TopStatusBar extends StatelessWidget {
  final String sourceLabel;
  final String scanQualityLabel;
  final bool isLive;

  const _TopStatusBar({
    required this.sourceLabel,
    required this.scanQualityLabel,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xCC10161D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.wifi : Icons.science,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            sourceLabel,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Text(
            scanQualityLabel,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  final double depth;
  final String risk;
  final String saferSide;
  final int pointCount;

  const _BottomHud({
    required this.depth,
    required this.risk,
    required this.saferSide,
    required this.pointCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xD910161D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(child: _HudValue(label: 'Depth', value: depth.toStringAsFixed(2))),
          Expanded(child: _HudValue(label: 'Risk', value: risk)),
          Expanded(child: _HudValue(label: 'Safe', value: saferSide)),
          Expanded(child: _HudValue(label: 'Pts', value: '$pointCount')),
        ],
      ),
    );
  }
}

class _HudValue extends StatelessWidget {
  final String label;
  final String value;

  const _HudValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}