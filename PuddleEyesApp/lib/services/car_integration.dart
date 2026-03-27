import 'package:flutter/services.dart';
import 'package:puddle_eyes_app/services/parser_service.dart';

class CarIntegration {
    static const platform = const MethodChannel('puddleeyes/car');

    static Future<void> sendDataToCar(List<Point3D> points) async {
        try {
            await platform.invokeMethod('updateRadar', points);
            await platform.invokeMethod('updateTrajectory', points);
        } on PlatformException catch (e) {
            print("Erreur Car Integration : ${e.message}");
        }
    }
}