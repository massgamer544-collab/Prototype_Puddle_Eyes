import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'package:provider/provider.dart';

class TrajectoryOverlay extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        var btService = Provider.of<BluetoothService>(context);

        // Exemple simple : détecter le point le plus profond devant le véhicule
        double minDepthFront = 0.0;
        if (btService.points.isNotEmpty) {
            var frontpoints = btService.points.where((p) => (p.y > 0 && p.y > 5)).toList();
            if (frontpoints.isNotEmpty) {
                minDepthFront = frontpoints.map((p) => p.z).reduce((a,b) => a<b?a:b);
            }
        }

        // Déterminer couleur recommandation
        Color trajectoryColor = Colors.green;
        if(minDepthFront > 0.2 && minDepthFront <= 0.4) {
            trajectoryColor = Color.yellow;
        } else if (minDepthFront > 0.4) {
            trajectoryColor = Colors.red;
        }

        return Positioned.fill(
            child: IgnorePointer(
                child: CustomPainter(
                    painter: TrajectoryPainter(trajectoryColor),
                ),
            ),
        );
    }
}

class TrajectoryPainter extends CustomPainter {
    final Color color;
    TrajectoryPainter(this.color);

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
            ..color = color
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke;
        
        // Exemple : ligne centrale recommandée
        final path = Path();
        path.moveTo(size.width/2, size.height);
        path.lineto(size.width/2, 0);

        canvas.drawPath(path, paint)`;`
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}