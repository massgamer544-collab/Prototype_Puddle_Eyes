import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_eyes_app/services/bluetooth_service.dart';
import 'package:puddle_eyes_app/services/parser_service.dart';

class DetectedObstacle {
  final Point3D point;
  final double surroundingDepth;
  final double protrusion;
  final double estimatedWidth;

  const DetectedObstacle({
    required this.point,
    required this.surroundingDepth,
    required this.protrusion,
    required this.estimatedWidth,
  });
}

DetectedObstacle? detectPrimaryObstacle(List<Point3D> points) {
  if (points.length < 3) return null;

  final sorted = [...points]..sort((a, b) => a.x.compareTo(b.x));

  for (int i = 1; i < sorted.length - 1; i++) {
    final left = sorted[i - 1];
    final mid = sorted[i];
    final right = sorted[i + 1];

    final surroundingDepth = (left.z + right.z) / 2.0;
    final protrusion = surroundingDepth - mid.z;

    if (protrusion > 0.18) {
      final estimatedWidth = (right.x - left.x).abs();

      return DetectedObstacle(
        point: mid,
        surroundingDepth: surroundingDepth,
        protrusion: protrusion,
        estimatedWidth: estimatedWidth,
      );
    }
  }

  return null;
}

class CameraOverlayScreen extends StatelessWidget {
  const CameraOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bt = Provider.of<BluetoothService>(context);
    final obstacle = detectPrimaryObstacle(bt.points);

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final markerPosition = obstacle != null
              ? _projectObstacleToScreen(
                  obstacle.point,
                  constraints.maxWidth,
                  constraints.maxHeight,
                )
              : null;

          return Stack(
            children: [
              const _MockCameraBackground(),
              _DepthOverlay(
                points: bt.points,
                leftDepth: bt.leftDepth,
                centerDepth: bt.centerDepth,
                rightDepth: bt.rightDepth,
                hasLeftObstacle: bt.hasLeftObstacle,
                hasCenterObstacle: bt.hasCenterObstacle,
                hasRightObstacle: bt.hasRightObstacle,
                saferSide: bt.saferSide,
                risk: bt.riskLabel,
              ),
              if (obstacle != null && markerPosition != null)
                Positioned(
                  left: markerPosition.dx - 22,
                  top: markerPosition.dy - 22,
                  child: GestureDetector(
                    onTap: () => _showObstacleDetails(context, obstacle),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.30),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFFD54F),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: Column(
                  children: [
                    _TopStatusBar(
                      sourceLabel: bt.sourceLabel,
                      confidenceLabel: bt.scanQualityLabel,
                      isLive: bt.isLive,
                    ),
                    const Spacer(),
                    _BottomHud(
                      depth: bt.maxDepth,
                      risk: bt.riskLabel,
                      saferSide: bt.saferSide,
                      pointCount: bt.points.length,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: SafeArea(
                  child: FloatingActionButton.small(
                    heroTag: 'controls_menu',
                    backgroundColor: const Color(0xCC10161D),
                    foregroundColor: Colors.white,
                    onPressed: () => _showControls(context),
                    child: const Icon(Icons.tune),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _projectObstacleToScreen(Point3D p, double width, double height) {
    final horizonY = height * 0.32;
    final bottomY = height * 0.93;

    final x = ((p.x + 1.0) / 2.0) * width;
    final yBase = horizonY + (bottomY - horizonY) * 0.58;
    final y = yBase - ((0.30 - p.z) * 120).clamp(-20.0, 60.0);

    return Offset(x, y);
  }

  void _showObstacleDetails(BuildContext context, DetectedObstacle obstacle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131A22),
          title: const Text(
            'Obstacle detected',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Protrusion',
                '${obstacle.protrusion.toStringAsFixed(2)} m',
              ),
              _detailRow(
                'Estimated width',
                '${obstacle.estimatedWidth.toStringAsFixed(2)} m',
              ),
              _detailRow(
                'Surrounding depth',
                '${obstacle.surroundingDepth.toStringAsFixed(2)} m',
              ),
              _detailRow(
                'Object depth',
                '${obstacle.point.z.toStringAsFixed(2)} m',
              ),
              const SizedBox(height: 10),
              const Text(
                'Estimate based on local depth anomaly.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showControls(BuildContext context) {
    final bt = Provider.of<BluetoothService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.82,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Scan Controls',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _ControlButton(
                          icon: Icons.wifi,
                          label: 'Live ESP32',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startLiveHttpScan();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.horizontal_rule,
                          label: 'Flat',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationFlat();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.warning_amber,
                          label: 'Mud hole',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationMudHole();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.turn_left,
                          label: 'Left safe path',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationLeftSafePath();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.turn_right,
                          label: 'Right safe path',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationRightSafePath();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.landscape,
                          label: 'Deep wide hole',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationDeepWideHole();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.blur_on,
                          label: 'Ultra detailed',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationUltraDetailedHole();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.crisis_alert,
                          label: 'Hole with stick',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationHoleWithStick();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.keyboard_arrow_right,
                          label: 'Dual right deep',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationDualSensorRightDeep();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.keyboard_arrow_left,
                          label: 'Dual left deep',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationDualSensorLeftDeep();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.balance,
                          label: 'Dual balanced caution',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationDualSensorBalancedCaution();
                          },
                        ),
                        _ControlButton(
                          icon: Icons.report_problem,
                          label: 'Dual obstacle right',
                          onTap: () {
                            Navigator.pop(context);
                            bt.startSimulationDualSensorObstacleRight();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MockCameraBackground extends StatelessWidget {
  const _MockCameraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2B3138),
            Color(0xFF3D342B),
            Color(0xFF2F261E),
            Color(0xFF1C1A18),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _MockCameraPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _MockCameraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.32;

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF4A5A67),
          Color(0xFF6C7A84),
          Color(0xFF8C8D80),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizonY));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY), skyPaint);

    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF64503D),
          Color(0xFF4A3828),
          Color(0xFF2B2118),
        ],
      ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY));

    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      groundPaint,
    );

    final pathPaint = Paint()
      ..color = const Color(0x55D8C3A5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.38, horizonY)
      ..lineTo(size.width * 0.62, horizonY)
      ..lineTo(size.width * 0.82, size.height)
      ..close();

    canvas.drawPath(path, pathPaint);

    final detailPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;

    for (int i = 0; i < 22; i++) {
      final y = horizonY + ((size.height - horizonY) / 22) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i * 0.6)),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        points: points,
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
  final List<Point3D> points;
  final double leftDepth;
  final double centerDepth;
  final double rightDepth;
  final bool hasLeftObstacle;
  final bool hasCenterObstacle;
  final bool hasRightObstacle;
  final String saferSide;
  final String risk;

  _DepthOverlayPainter({
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
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.32;
    final bottomY = size.height * 0.93;

    final effectiveLeft = _effectiveDangerDepth(leftDepth, hasLeftObstacle);
    final effectiveCenter =
        _effectiveDangerDepth(centerDepth, hasCenterObstacle);
    final effectiveRight = _effectiveDangerDepth(rightDepth, hasRightObstacle);

    _drawZone(
      canvas,
      size,
      horizonY,
      bottomY,
      xCenterFactor: 0.22,
      widthFactor: 0.22,
      depth: effectiveLeft,
    );

    _drawZone(
      canvas,
      size,
      horizonY,
      bottomY,
      xCenterFactor: 0.50,
      widthFactor: 0.24,
      depth: effectiveCenter,
    );

    _drawZone(
      canvas,
      size,
      horizonY,
      bottomY,
      xCenterFactor: 0.78,
      widthFactor: 0.22,
      depth: effectiveRight,
    );

    _drawSafeSideArrow(canvas, size, saferSide);
    _drawCenterReticle(canvas, size);

    if (risk == 'DANGER') {
      final framePaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;

      canvas.drawRect(
        Rect.fromLTWH(6, 6, size.width - 12, size.height - 12),
        framePaint,
      );
    }
  }

  double _effectiveDangerDepth(double depth, bool hasObstacle) {
    if (!hasObstacle) return depth;
    final boosted = depth + 0.45;
    return boosted.clamp(0.0, 1.5);
  }

  void _drawZone(
    Canvas canvas,
    Size size,
    double horizonY,
    double bottomY, {
    required double xCenterFactor,
    required double widthFactor,
    required double depth,
  }) {
    final centerX = size.width * xCenterFactor;
    final topWidth = size.width * widthFactor * 0.35;
    final bottomWidth = size.width * widthFactor;

    final color = _depthColor(depth);

    final path = Path()
      ..moveTo(centerX - topWidth / 2, horizonY)
      ..lineTo(centerX + topWidth / 2, horizonY)
      ..lineTo(centerX + bottomWidth / 2, bottomY)
      ..lineTo(centerX - bottomWidth / 2, bottomY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.08),
          color.withOpacity(0.22),
          color.withOpacity(0.34),
        ],
      ).createShader(
        Rect.fromLTRB(
          centerX - bottomWidth / 2,
          horizonY,
          centerX + bottomWidth / 2,
          bottomY,
        ),
      );

    canvas.drawPath(path, fillPaint);
  }

  Color _depthColor(double depth) {
    if (depth <= 0.12) return const Color(0xFF00E676);
    if (depth <= 0.22) return Colors.orangeAccent;
    if (depth <= 0.40) return const Color(0xFFFF7043);
    return Colors.redAccent;
  }

  void _drawSafeSideArrow(Canvas canvas, Size size, String saferSide) {
    if (saferSide != 'LEFT' && saferSide != 'RIGHT') return;

    final paint = Paint()
      ..color = const Color(0xCC00E676)
      ..style = PaintingStyle.fill;

    final cy = size.height * 0.80;
    final cx = size.width / 2;
    final path = Path();

    if (saferSide == 'LEFT') {
      path.moveTo(cx - 100, cy);
      path.lineTo(cx - 45, cy - 24);
      path.lineTo(cx - 45, cy - 10);
      path.lineTo(cx + 5, cy - 10);
      path.lineTo(cx + 5, cy + 10);
      path.lineTo(cx - 45, cy + 10);
      path.lineTo(cx - 45, cy + 24);
    } else {
      path.moveTo(cx + 100, cy);
      path.lineTo(cx + 45, cy - 24);
      path.lineTo(cx + 45, cy - 10);
      path.lineTo(cx - 5, cy - 10);
      path.lineTo(cx - 5, cy + 10);
      path.lineTo(cx + 45, cy + 10);
      path.lineTo(cx + 45, cy + 24);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCenterReticle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.24)
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height * 0.62;

    canvas.drawCircle(Offset(cx, cy), 18, paint);
    canvas.drawLine(Offset(cx - 30, cy), Offset(cx - 12, cy), paint);
    canvas.drawLine(Offset(cx + 12, cy), Offset(cx + 30, cy), paint);
    canvas.drawLine(Offset(cx, cy - 30), Offset(cx, cy - 12), paint);
    canvas.drawLine(Offset(cx, cy + 12), Offset(cx, cy + 30), paint);
  }

  @override
  bool shouldRepaint(covariant _DepthOverlayPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.leftDepth != leftDepth ||
        oldDelegate.centerDepth != centerDepth ||
        oldDelegate.rightDepth != rightDepth ||
        oldDelegate.hasLeftObstacle != hasLeftObstacle ||
        oldDelegate.hasCenterObstacle != hasCenterObstacle ||
        oldDelegate.hasRightObstacle != hasRightObstacle ||
        oldDelegate.saferSide != saferSide ||
        oldDelegate.risk != risk;
  }
}

class _TopStatusBar extends StatelessWidget {
  final String sourceLabel;
  final String confidenceLabel;
  final bool isLive;

  const _TopStatusBar({
    required this.sourceLabel,
    required this.confidenceLabel,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 56, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC10161D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF26323D)),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.wifi : Icons.science,
            color: isLive ? const Color(0xFF4DD0E1) : Colors.white70,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            sourceLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            confidenceLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
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
    Color riskColor = const Color(0xFF00E676);
    if (risk == 'CAUTION') {
      riskColor = Colors.orangeAccent;
    } else if (risk == 'DANGER') {
      riskColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xD910161D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26323D)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HudValue(
              label: 'Depth',
              value: '${depth.toStringAsFixed(2)} m',
            ),
          ),
          Expanded(
            child: _HudValue(
              label: 'Risk',
              value: risk,
              valueColor: riskColor,
            ),
          ),
          Expanded(
            child: _HudValue(
              label: 'Safe side',
              value: saferSide,
            ),
          ),
          Expanded(
            child: _HudValue(
              label: 'Points',
              value: '$pointCount',
            ),
          ),
        ],
      ),
    );
  }
}

class _HudValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HudValue({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        tileColor: const Color(0xFF1B2530),
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap,
      ),
    );
  }
}