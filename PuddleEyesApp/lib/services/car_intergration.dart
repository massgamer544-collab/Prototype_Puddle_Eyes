import 'package:flutter/services.dart';

class CarIntegration {
    static const platform = MethodChannel('puddleeyes/car');

    static Future<void> sendDataToCar(List<Mao<String,dynamic>> points) async {
        try {
            await platform.invokeMethod('updateRadar',points);
            await platform.invokeMethod('updateTrajectory', pointsData);
        } on PlatformException catch (e) {
            print("Erreur Car Integration : ${e.message}");
        }
    }
}