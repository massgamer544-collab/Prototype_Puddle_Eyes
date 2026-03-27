import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_eyes_app/services/bluetooth_service.dart';
import 'package:puddle_eyes_app/services/parser_service.dart';

class Heatmap3D extends StatelessWidget {
  const Heatmap3D({super.key});

  @override
  Widget build(BuildContext context) {
    final btService = Provider.of<BluetoothService>(context);

    return CustomPaint(
      painter: RealisticTerrainPainter(btService.points),
      child: Container(),
    );
  }
}

class RealisticTerrainPainter extends CustomPainter {
  final List<Point3D> points;

  RealisticTerrainPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF061018),
          Color(0xFF0A1722),
          Color(0xFF0C1117),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    final horizonY = size.height * 0.18;
    final bottomY = size.height * 0.93;

    _drawAtmosphericGlow(canvas, size, horizonY);
    _drawPerspectiveGrid(canvas, size, horizonY, bottomY);

    if (points.isEmpty) {
      _drawNoData(canvas, size);
      return;
    }

    final raw = [...points]..sort((a, b) => a.x.compareTo(b.x));
    final terrainBase = _lightlySmoothedPoints(raw);

    const cols = 84;
    const rows = 46;

    final mesh = <List<Offset>>[];
    final depthMesh = <List<double>>[];
    final rowTValues = <double>[];

    for (int row = 0; row <= rows; row++) {
      final rowT = row / rows;
      rowTValues.add(rowT);

      final perspectiveY =
          horizonY + (bottomY - horizonY) * math.pow(rowT, 1.70);
      final widthFactor = 0.08 + rowT * 0.92;
      final rowWidth = size.width * widthFactor;
      final leftX = (size.width - rowWidth) / 2;

      final rowOffsets = <Offset>[];
      final rowDepths = <double>[];

      for (int col = 0; col <= cols; col++) {
        final colT = col / cols;
        final xNorm = -1.0 + (2.0 * colT);

        final depth = _interpolateDepth(terrainBase, xNorm);

        final nearFieldAmplification = 16 + 195 * rowT;
        final terrainY = perspectiveY + depth * nearFieldAmplification;

        final screenX = leftX + rowWidth * colT;
        final screenY = terrainY;

        rowOffsets.add(Offset(screenX, screenY));
        rowDepths.add(depth);
      }

      mesh.add(rowOffsets);
      depthMesh.add(rowDepths);
    }

    _drawTerrainShadow(canvas, mesh);
    _drawLitTerrainMesh(canvas, mesh, depthMesh, rowTValues);
    _drawContourLines(canvas, mesh, rowTValues);
    _drawRidgeHighlights(canvas, mesh, depthMesh);
    _drawRawSensorPoints(canvas, size, raw, horizonY, bottomY);
    _drawObstacleSpikes(canvas, size, raw, terrainBase, horizonY, bottomY);
    _drawVignette(canvas, size);
  }

  void _drawAtmosphericGlow(Canvas canvas, Size size, double horizonY) {
    final glowRect = Rect.fromCenter(
      center: Offset(size.width / 2, horizonY + 8),
      width: size.width * 1.3,
      height: size.height * 0.22,
    );

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2A6F87).withOpacity(0.16),
          const Color(0xFF2A6F87).withOpacity(0.04),
          Colors.transparent,
        ],
      ).createShader(glowRect);

    canvas.drawOval(glowRect, glowPaint);
  }

  void _drawPerspectiveGrid(
    Canvas canvas,
    Size size,
    double horizonY,
    double bottomY,
  ) {
    final gridPaint = Paint()
      ..color = const Color(0xFF173041).withOpacity(0.45)
      ..strokeWidth = 1;

    for (int i = 0; i <= 11; i++) {
      final t = i / 11.0;
      final y = horizonY + (bottomY - horizonY) * math.pow(t, 1.75);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = -10; i <= 10; i++) {
      final xTop = size.width / 2 + i * 12.0;
      final xBottom = size.width / 2 + i * 72.0;
      canvas.drawLine(
        Offset(xTop, horizonY),
        Offset(xBottom, bottomY),
        gridPaint,
      );
    }
  }

  void _drawTerrainShadow(Canvas canvas, List<List<Offset>> mesh) {
    if (mesh.isEmpty) return;

    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = Colors.black.withOpacity(0.28);

    final path = Path();
    final lastRow = mesh.last;

    path.moveTo(lastRow.first.dx, lastRow.first.dy + 18);
    for (final p in lastRow) {
      path.lineTo(p.dx, p.dy + 18);
    }
    path.lineTo(lastRow.last.dx, lastRow.last.dy + 60);
    path.lineTo(lastRow.first.dx, lastRow.first.dy + 60);
    path.close();

    canvas.drawPath(path, shadowPaint);
  }

  void _drawLitTerrainMesh(
    Canvas canvas,
    List<List<Offset>> mesh,
    List<List<double>> depthMesh,
    List<double> rowTValues,
  ) {
    final lightDir = _normalize(const Offset(-0.7, -1.0));

    for (int row = 0; row < mesh.length - 1; row++) {
      for (int col = 0; col < mesh[row].length - 1; col++) {
        final p1 = mesh[row][col];
        final p2 = mesh[row][col + 1];
        final p3 = mesh[row + 1][col + 1];
        final p4 = mesh[row + 1][col];

        final d1 = depthMesh[row][col];
        final d2 = depthMesh[row][col + 1];
        final d3 = depthMesh[row + 1][col + 1];
        final d4 = depthMesh[row + 1][col];

        final avgDepth = (d1 + d2 + d3 + d4) / 4.0;

        final dx = ((d2 + d3) - (d1 + d4)) * 0.5;
        final dy = ((d4 + d3) - (d1 + d2)) * 0.5;

        final normal2D = _normalize(Offset(-dx, -dy));
        final shade = (normal2D.dx * lightDir.dx + normal2D.dy * lightDir.dy);
        final shade01 = ((shade + 1.0) / 2.0).clamp(0.0, 1.0);

        final distanceFade = (1.0 - rowTValues[row]).clamp(0.0, 1.0);
        final fogFactor = 0.30 * distanceFade;

        final baseColor = _depthColor(avgDepth, shade01);
        final finalColor = Color.lerp(
          baseColor,
          const Color(0xFF385564),
          fogFactor,
        )!;

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = finalColor;

        final path = Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..lineTo(p4.dx, p4.dy)
          ..close();

        canvas.drawPath(path, fillPaint);
      }
    }
  }

  void _drawContourLines(
    Canvas canvas,
    List<List<Offset>> mesh,
    List<double> rowTValues,
  ) {
    for (int row = 0; row < mesh.length; row++) {
      final opacity = 0.12 + (rowTValues[row] * 0.22);

      final linePaint = Paint()
        ..color = const Color(0xFF7FDBFF).withOpacity(opacity)
        ..strokeWidth = row % 4 == 0 ? 1.2 : 0.8
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(mesh[row].first.dx, mesh[row].first.dy);
      for (int col = 1; col < mesh[row].length; col++) {
        path.lineTo(mesh[row][col].dx, mesh[row][col].dy);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawRidgeHighlights(
    Canvas canvas,
    List<List<Offset>> mesh,
    List<List<double>> depthMesh,
  ) {
    final ridgePaint = Paint()
      ..color = const Color(0xFFB2F1FF).withOpacity(0.10)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int row = 1; row < mesh.length - 1; row += 2) {
      final path = Path();
      bool started = false;

      for (int col = 1; col < mesh[row].length - 1; col++) {
        final current = depthMesh[row][col];
        final left = depthMesh[row][col - 1];
        final right = depthMesh[row][col + 1];

        final isRidge = current < left && current < right;

        if (isRidge) {
          final p = mesh[row][col];
          if (!started) {
            path.moveTo(p.dx, p.dy);
            started = true;
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
      }

      if (started) {
        canvas.drawPath(path, ridgePaint);
      }
    }
  }

  void _drawRawSensorPoints(
    Canvas canvas,
    Size size,
    List<Point3D> raw,
    double horizonY,
    double bottomY,
  ) {
    final outerGlow = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.14);

    final midGlow = Paint()
      ..color = const Color(0xFF80DEEA).withOpacity(0.28);

    final pointPaint = Paint()..color = Colors.white;

    for (final p in raw) {
      final pos = _projectPoint(p, size, horizonY, bottomY);

      canvas.drawCircle(pos, 11, outerGlow);
      canvas.drawCircle(pos, 6, midGlow);
      canvas.drawCircle(pos, 2.8, pointPaint);
    }
  }

  void _drawObstacleSpikes(
    Canvas canvas,
    Size size,
    List<Point3D> raw,
    List<Point3D> baseline,
    double horizonY,
    double bottomY,
  ) {
    for (final p in raw) {
      final baselineDepth = _interpolateDepth(baseline, p.x);
      final protrusion = baselineDepth - p.z;

      if (protrusion < 0.18) continue;

      final basePos = _projectPoint(
        Point3D(x: p.x, y: p.y, z: baselineDepth),
        size,
        horizonY,
        bottomY,
      );

      final tipPos = _projectPoint(p, size, horizonY, bottomY);
      final exaggeration = (55 + protrusion * 320).clamp(50.0, 160.0);
      final sharpTip = Offset(tipPos.dx, tipPos.dy - exaggeration);

      final glowPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.20)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      final spikePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFFFFD54F),
            Color(0xFFFF7043),
            Color(0xFFFF1744),
          ],
        ).createShader(Rect.fromPoints(basePos, sharpTip))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.redAccent.withOpacity(0.80);

      canvas.drawLine(basePos, sharpTip, glowPaint);
      canvas.drawLine(basePos, sharpTip, spikePaint);
      canvas.drawCircle(basePos, 7, ringPaint);
      canvas.drawCircle(
        sharpTip,
        6,
        Paint()..color = Colors.white.withOpacity(0.95),
      );
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    final vignetteRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withOpacity(0.18),
        ],
        stops: const [0.0, 0.72, 1.0],
      ).createShader(vignetteRect);

    canvas.drawRect(vignetteRect, vignettePaint);
  }

  Offset _projectPoint(
    Point3D p,
    Size size,
    double horizonY,
    double bottomY,
  ) {
    final xT = ((p.x + 1.0) / 2.0).clamp(0.0, 1.0);
    final x = size.width * xT;

    final rowT = 0.88;
    final yPerspective = horizonY + (bottomY - horizonY) * math.pow(rowT, 1.72);
    final y = yPerspective + p.z * 165.0;

    return Offset(x, y);
  }

  List<Point3D> _lightlySmoothedPoints(List<Point3D> input) {
    if (input.length < 3) return input;

    final out = <Point3D>[];

    for (int i = 0; i < input.length; i++) {
      if (i == 0 || i == input.length - 1) {
        out.add(input[i]);
        continue;
      }

      final prev = input[i - 1];
      final curr = input[i];
      final next = input[i + 1];

      final z = (prev.z * 0.25) + (curr.z * 0.70) + (next.z * 0.15);

      out.add(Point3D(x: curr.x, y: curr.y, z: z));
    }

    return out;
  }

  double _interpolateDepth(List<Point3D> sorted, double x) {
    if (sorted.isEmpty) return 0.0;
    if (sorted.length == 1) return sorted.first.z;

    if (x <= sorted.first.x) return sorted.first.z;
    if (x >= sorted.last.x) return sorted.last.z;

    for (int i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i];
      final b = sorted[i + 1];

      if (x >= a.x && x <= b.x) {
        final t = (x - a.x) / (b.x - a.x);
        final smoothT = t * t * (3 - 2 * t);
        return a.z + (b.z - a.z) * smoothT;
      }
    }

    return sorted.last.z;
  }

  Color _depthColor(double depth, double shade01) {
    late Color base;

    if (depth <= 0.12) {
      base = const Color(0xFF1D6C57);
    } else if (depth <= 0.22) {
      base = const Color(0xFF2B8A61);
    } else if (depth <= 0.35) {
      base = const Color(0xFF8E6F1F);
    } else if (depth <= 0.50) {
      base = const Color(0xFF96511E);
    } else {
      base = const Color(0xFF7E1B1B);
    }

    final brighten = 0.68 + (shade01 * 0.48);

    return Color.fromARGB(
      255,
      (base.red * brighten).clamp(0, 255).toInt(),
      (base.green * brighten).clamp(0, 255).toInt(),
      (base.blue * brighten).clamp(0, 255).toInt(),
    );
  }

  Offset _normalize(Offset v) {
    final len = math.sqrt(v.dx * v.dx + v.dy * v.dy);
    if (len == 0) return const Offset(0, -1);
    return Offset(v.dx / len, v.dy / len);
  }

  void _drawNoData(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'No sonar data',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant RealisticTerrainPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}