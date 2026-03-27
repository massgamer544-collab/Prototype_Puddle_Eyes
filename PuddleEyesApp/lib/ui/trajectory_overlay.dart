import 'package:flutter/material.dart';
import 'package:puddle_eyes_app/services/parser_service.dart';

class TrajectoryOverlay extends StatelessWidget {
  final List<Point3D> points;

  const TrajectoryOverlay({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrajectoryPainter(points),
      size: Size.infinite,
    );
  }
}

class _TrajectoryPainter extends CustomPainter {
  final List<Point3D> points;

  _TrajectoryPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = ((p.x + 1.0) / 2.0) * size.width;
      final y = size.height * 0.75;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}